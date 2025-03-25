import Foundation
import MapKit

class RouteService {
    /// Calculate a route between two points
    /// - Parameters:
    ///   - source: Starting coordinate
    ///   - destination: Ending coordinate
    ///   - transportType: Type of transportation to use
    ///   - completion: Handler called with the route result
    static func calculateRoute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: TransportType,
        completion: @escaping (Result<MKRoute, Error>) -> Void
    ) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transportType.mapKitType

        MKDirections(request: request).calculate { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let route = response?.routes.first else {
                completion(
                    .failure(
                        NSError(
                            domain: "RouteService", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "No route found"])))
                return
            }

            completion(.success(route))
        }
    }

    /// Get a transport type from an activity description
    /// - Parameter description: The activity description string
    /// - Returns: The identified transport type
    static func getTransportTypeFromDescription(_ description: String) -> TransportType {
        return TransportType.fromDescription(description)
    }
}
