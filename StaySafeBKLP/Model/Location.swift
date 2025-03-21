import Foundation

/// Represents a specific place for journeys.
struct Location: Codable, Identifiable {
    /// Unique identifier for the location
    var locationID: Int
    /// Name of the location
    var locationName: String
    /// Description of the location
    var locationDescription: String
    /// Address of the location
    var locationAddress: String
    /// Postal code of the location
    var locationPostcode: String?
    /// Latitude coordinate of the location
    var locationLatitude: Double
    /// Longitude coordinate of the location
    var locationLongitude: Double

    /// Computed id property for Identifiable conformance
    var id: Int { locationID }

    enum CodingKeys: String, CodingKey {
        case locationID = "LocationID"
        case locationName = "LocationName"
        case locationDescription = "LocationDescription"
        case locationAddress = "LocationAddress"
        case locationPostcode = "LocationPostcode"
        case locationLatitude = "LocationLatitude"
        case locationLongitude = "LocationLongitude"
    }
}
