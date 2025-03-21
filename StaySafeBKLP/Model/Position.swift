import Foundation

/// Records GPS coordinates and timestamps associated with an activity.
struct Position: Codable, Identifiable {
    /// Unique identifier for the position record
    var positionID: Int
    /// ID of the related activity
    var positionActivityID: Int
    /// Name of the associated activity (extended field)
    var positionActivityName: String?
    /// Latitude coordinate of the recorded position
    var positionLatitude: Double
    /// Longitude coordinate of the recorded position
    var positionLongitude: Double
    /// Timestamp of the recorded position
    var positionTimestamp: Int

    /// Computed id property for Identifiable conformance
    var id: Int { positionID }

    enum CodingKeys: String, CodingKey {
        case positionID = "PositionID"
        case positionActivityID = "PositionActivityID"
        case positionActivityName = "PositionActivityName"
        case positionLatitude = "PositionLatitude"
        case positionLongitude = "PositionLongitude"
        case positionTimestamp = "PositionTimestamp"
    }
}
