import Foundation

/// Represents a planned journey between locations at a specified time.
struct Activity: Codable, Identifiable {
    /// Unique identifier for the activity
    var activityID: Int
    /// Name of the activity
    var activityName: String
    /// ID of the user associated with the activity
    var activityUserID: Int
    /// Username of the associated user (extended field)
    var activityUsername: String?
    /// Description of the activity
    var activityDescription: String
    /// ID of the departure location
    var activityFromID: Int
    /// Name of the departure location (extended field)
    var activityFromName: String?
    /// Date and time of departure
    var activityLeave: String
    /// ID of the arrival location
    var activityToID: Int
    /// Name of the arrival location (extended field)
    var activityToName: String?
    /// Date and time of arrival
    var activityArrive: String
    /// ID representing the status of the activity
    var activityStatusID: Int
    /// Name of the activity status (extended field)
    var activityStatusName: String?

    /// Computed id property for Identifiable conformance
    var id: Int { activityID }

    enum CodingKeys: String, CodingKey {
        case activityID = "ActivityID"
        case activityName = "ActivityName"
        case activityUserID = "ActivityUserID"
        case activityUsername = "ActivityUsername"
        case activityDescription = "ActivityDescription"
        case activityFromID = "ActivityFromID"
        case activityFromName = "ActivityFromName"
        case activityLeave = "ActivityLeave"
        case activityToID = "ActivityToID"
        case activityToName = "ActivityToName"
        case activityArrive = "ActivityArrive"
        case activityStatusID = "ActivityStatusID"
        case activityStatusName = "ActivityStatusName"
    }
}
