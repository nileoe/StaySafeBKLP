import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case unknownError

    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

/// Base API service providing generic HTTP methods
class APIService {
    private let baseURL = "https://staysafeserver-production.up.railway.app/staysafe/v1/api"
    private let debugMode = true  // Enable additional logging

    // Simplified logging function
    private func logDecodingError<T: Codable>(data: Data, type: T.Type, error: Error) {
        print("===== DECODING ERROR =====")
        print("Target type: \(type)")
        print("Error: \(error)")

        // Print raw JSON without any parsing
        if let jsonString = String(data: data, encoding: .utf8) {
            print("\nRaw JSON data:")
            print(jsonString)
        }
        print("===== END DECODING ERROR =====")
    }

    /// Generic GET request with typed response
    func get<T: Codable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if debugMode {
            print("Making GET request to: \(url)")
        }

        return try await performRequestWithPossibleArrayResponse(request: request)
    }

    /// Generic POST request
    func post<T: Codable, U: Codable>(endpoint: String, body: T) async throws -> U {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData

            return try await performRequestWithPossibleArrayResponse(request: request)
        } catch {
            throw APIError.requestFailed(error)
        }
    }

    /// Generic PUT request
    func put<T: Codable, U: Codable>(endpoint: String, body: T) async throws -> U {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            return try await performRequestWithPossibleArrayResponse(request: request)
        } catch {
            throw APIError.requestFailed(error)
        }
    }

    /// Generic DELETE request
    func delete<T: Codable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return try await performRequestWithPossibleArrayResponse(request: request)
    }

    /// Helper method to perform requests that might return arrays or single objects
    private func performRequestWithPossibleArrayResponse<T: Codable>(request: URLRequest)
        async throws -> T
    {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.serverError(httpResponse.statusCode)
            }

            // Debug logging
//            if self.debugMode, let jsonString = String(data: data, encoding: .utf8) {
//                print("Response from \(request.url?.lastPathComponent ?? "unknown"):")
//                print(jsonString)
//            }

            // Try to determine if response is array or object
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
                throw APIError.invalidResponse
            }

            // First try to decode as expected type
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                // If expected type is an array but got a single object, wrap it
                if T.self is [Any].Type, !(jsonObject is [Any]) {
                    print("Expected array but got object, attempting to wrap in array...")

                    // Create a wrapper array
                    let wrappedData = try JSONSerialization.data(withJSONObject: [jsonObject])
                    return try JSONDecoder().decode(T.self, from: wrappedData)
                }
                // If expected type is a single object but got an array with one item, unwrap it
                else if !(T.self is [Any].Type), let array = jsonObject as? [Any], array.count == 1
                {
                    print("Expected object but got array, attempting to extract first item...")

                    // Extract first item from array
                    if let firstObject = array.first {
                        let singleItemData = try JSONSerialization.data(withJSONObject: firstObject)
                        return try JSONDecoder().decode(T.self, from: singleItemData)
                    }
                }

                // If all attempts failed, throw the original error
                self.logDecodingError(data: data, type: T.self, error: error)
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            debugPrint("Network error: \(error)")
            throw APIError.requestFailed(error)
        }
    }

    // Method only used for API testing, not needed for actual app features
    func getRawData(endpoint: String) async throws -> Any {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if debugMode {
            print("Making raw GET request to: \(url)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw APIError.serverError(httpResponse.statusCode)
        }

        return try JSONSerialization.jsonObject(with: data)
    }
}
