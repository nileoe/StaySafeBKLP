import Foundation

/// Represents a planned journey between locations at a specified time.
struct Activity: Codable, Identifiable, Equatable {
    var activityID: Int
    var activityName: String
    var activityUserID: Int
    var activityUsername: String? /// (extended field)
    var activityDescription: String
    var activityFromID: Int
    var activityFromName: String? /// (extended field)
    var activityLeave: String /// Date and time of departure
    var activityToID: Int /// ID of the arrival location
    var activityToName: String? /// (extended field)
    var activityArrive: String /// Date and time of arrival
    var activityStatusID: Int /// ID representing the status of the activity
    var activityStatusName: String? /// (extended field)

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
    private var status: ActivityStatus {
        ActivityStatus(rawValue: activityStatusID) ?? .cancelled
       }
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.activityID == rhs.activityID
    }
    
    func isCurrent() -> Bool {
        activityStatusID == 2 || activityStatusID == 3  // TODO not use?
    }
    func isPlanned() -> Bool {
        status == .planned
    }
    func hasStarted() -> Bool {
        status == .started
    }
    func isPaused() -> Bool {
        status == .paused
    }
    func isCancelled() -> Bool {
        status == .cancelled
    }
    func isCompleted() -> Bool {
        status == .completed
    }
}

