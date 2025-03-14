import SwiftUI
import Foundation

struct Trip: Codable, Identifiable {
    var id: Int
    var title: String
    var description: String

    var userId: Int
    var username: String
    
    var departureLocationId: Int
    var departureLocationName: String
    var departureTime: Date?

    var arrivalLocationId: Int
    var arrivalLocationName: String
    var arrivalTime: Date?

    var statusId: Int
    var statusName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ActivityID"
        case title = "ActivityName"
        case description = "ActivityDescription"

        case userId = "ActivityUserID"
        case username = "ActivityUsername"
        
        case departureLocationId = "ActivityFromID"
        case departureLocationName = "ActivityFromName"
        case departureTime = "ActivityLeave"
        
        case arrivalLocationId = "ActivityToID"
        case arrivalLocationName = "ActivityToName"
        case arrivalTime = "ActivityArrive"

        case statusId = "ActivityStatusID"
        case statusName = "ActivityStatusName"
    }
}

func getAllTrips() async throws -> [Trip] {
    print("get user called...")
    let endpoint = "https://softwarehub.uk/unibase/staysafe/v1/api/activities"
    guard let url = URL(string: endpoint) else {
        print("url is not valid")
        throw TripError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        print("response is not 200")
        throw TripError.invalidResponse
    }
    
    // Got status code of 200:
    // Data is valid and can be parsed to be returned
    do {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode([Trip].self, from: data)
    } catch {
        print("error when getting trip data")
        throw TripError.invalidData
    }
}

enum TripError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
