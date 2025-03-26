import Foundation

/// Represents a planned journey between locations at a specified time.
struct Activity: Codable, Identifiable, Equatable {
    var activityID: Int
    var activityName: String
    var activityUserID: Int
    var activityUsername: String? /// Username of the associated user (extended field)
    var activityDescription: String
    var activityFromID: Int
    var activityFromName: String? /// Name of the departure location (extended field)
    var activityLeave: String /// Date and time of departure
    var activityToID: Int /// ID of the arrival location
    var activityToName: String? /// Name of the arrival location (extended field)
    var activityArrive: String /// Date and time of arrival
    var activityStatusID: Int /// ID representing the status of the activity
    var activityStatusName: String? /// Name of the activity status (extended field)

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

    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.activityID == rhs.activityID
    }
    
    func isCurrent() -> Bool {
        activityStatusID >= 1 && activityStatusID <= 3
    }
}

