import Foundation

/// Represents a contact with detailed user information as returned by the users/contacts endpoint
struct ContactDetail: Codable, Identifiable {
    // User information
    var userID: Int
    var userFirstname: String
    var userLastname: String
    var userPhone: String
    var userUsername: String
    var userPassword: String
    var userLatitude: Double
    var userLongitude: Double
    var userTimestamp: Int
    var userImageURL: String?

    // Contact relationship information
    var userContactID: Int
    var userContactLabel: String
    var userContactDatecreated: String

    // Conform to Identifiable
    var id: Int { userContactID }

    // Full name computed property
    var fullName: String {
        "\(userFirstname) \(userLastname)"
    }
    
    func isTravelling() async -> Bool {
        let apiService = StaySafeAPIService()
        do {
            let activities = try await apiService.getActivities(userID: String(userID))
            for activity in activities {
                if (activity.isCurrent()) {
                    return true
                }
            }
        } catch {
            print("Error fetching activities: \(error)")
        }
        return false
    }

    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case userFirstname = "UserFirstname"
        case userLastname = "UserLastname"
        case userPhone = "UserPhone"
        case userUsername = "UserUsername"
        case userPassword = "UserPassword"
        case userLatitude = "UserLatitude"
        case userLongitude = "UserLongitude"
        case userTimestamp = "UserTimestamp"
        case userImageURL = "UserImageURL"
        case userContactID = "UserContactID"
        case userContactLabel = "UserContactLabel"
        case userContactDatecreated = "UserContactDatecreated"
    }
}

extension ContactDetail: ProfileDisplayable {}
