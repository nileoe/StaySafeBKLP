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
    func get<T: Codable>(endpoint: String, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if debugMode {
            print("Making GET request to: \(url)")
        }

        performRequest(request: request, completion: completion)
    }

    /// Generic POST request
    func post<T: Codable, U: Codable>(
        endpoint: String, body: T, completion: @escaping (Result<U, APIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            performRequest(request: request, completion: completion)
        } catch {
            completion(.failure(.requestFailed(error)))
        }
    }

    /// Generic PUT request
    func put<T: Codable, U: Codable>(
        endpoint: String, body: T, completion: @escaping (Result<U, APIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            performRequest(request: request, completion: completion)
        } catch {
            completion(.failure(.requestFailed(error)))
        }
    }

    /// Generic DELETE request
    func delete<T: Codable>(endpoint: String, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        performRequest(request: request, completion: completion)
    }

    /// Helper method to perform requests
    private func performRequest<T: Codable>(
        request: URLRequest,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Error handling first
                if let error = error {
                    debugPrint("Network error: \(error)")
                    completion(.failure(.requestFailed(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode),
                    let data = data
                else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    debugPrint("HTTP error: \(statusCode ?? -1)")
                    completion(
                        statusCode != nil
                            ? .failure(.serverError(statusCode!)) : .failure(.invalidResponse))
                    return
                }

                // Debug logging (kept compact)
                if self.debugMode, let jsonString = String(data: data, encoding: .utf8) {
                    print("Response from \(request.url?.lastPathComponent ?? "unknown"):")
                    print(jsonString)

                    // Simplified array vs object logging
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
                        let isArrayResponse = jsonObject is [Any]
                        let isArrayExpected = T.self is [Any].Type

                        if isArrayResponse && !isArrayExpected {
                            print(
                                "Note: API returned array for single object request (handled by wrapper)"
                            )
                        } else if !isArrayResponse && isArrayExpected {
                            print("Warning: Expected array but got object")
                        }
                    }
                }

                // Decoding attempt
                do {
                    completion(.success(try JSONDecoder().decode(T.self, from: data)))
                } catch {
                    debugPrint("Decoding error: \(error)")
                    self.logDecodingError(data: data, type: T.self, error: error)
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }

    // Method only used for API testing, not needed for actual app features
    func getRawData(endpoint: String, completion: @escaping (Result<Any, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if debugMode {
            print("Making raw GET request to: \(url)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Error handling code...
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }

                // Process the data
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    completion(.success(json))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
}
