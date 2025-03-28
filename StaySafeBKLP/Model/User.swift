import Foundation

/// Represents a system user, including individuals undertaking activities and those monitoring them.
struct User: Codable, Identifiable {
    /// Unique identifier for the user
    var userID: Int
    /// First name of the user
    var userFirstname: String
    /// Last name of the user
    var userLastname: String
    /// Phone number of the user
    var userPhone: String
    /// Username for the user
    var userUsername: String
    /// Encrypted password for authentication
    var userPassword: String
    /// Last known latitude of the user
    var userLatitude: Double
    /// Last known longitude of the user
    var userLongitude: Double
    /// Timestamp of the last known location update
    var userTimestamp: Int
    /// URL of the user's profile image
    var userImageURL: String?

    /// Computed id property for Identifiable conformance
    var id: Int { userID }

    /// Computed full name property
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
    }
}

extension User: ProfileDisplayable {}
