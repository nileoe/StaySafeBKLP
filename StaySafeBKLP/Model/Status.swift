import Foundation

/// Represents an enumerated set of activity statuses.
struct Status: Codable, Identifiable {
    /// Unique identifier for the status
    var statusID: Int
    /// Name of the status (e.g., "Planned", "Started")
    var statusName: String
    /// Order of the status for sorting
    var statusOrder: Int

    /// Computed id property for Identifiable conformance
    var id: Int { statusID }

    enum CodingKeys: String, CodingKey {
        case statusID = "StatusID"
        case statusName = "StatusName"
        case statusOrder = "StatusOrder"
    }
}
