import CoreLocation
import MapKit

struct TripDetails {
    var destination: CLLocationCoordinate2D
    var destinationName: String
    var transportType: MKDirectionsTransportType
    var departureTime: Date
    var estimatedArrivalTime: Date?
    var route: MKRoute?
}
