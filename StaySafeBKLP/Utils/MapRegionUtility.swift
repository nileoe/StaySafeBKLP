import MapKit
import SwiftUI

struct MapRegionUtility {
    /// Default zoom level for general map views (delta values)
    static let defaultZoom = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

    /// Closer zoom level for detailed views
    static let closeZoom = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    /// Create a standard region centered on a coordinate
    static func region(center: CLLocationCoordinate2D, span: MKCoordinateSpan? = nil)
        -> MKCoordinateRegion
    {
        MKCoordinateRegion(
            center: center,
            span: span ?? defaultZoom
        )
    }

    /// Create a region centered on the user's location
    static func userRegion(userLocation: CLLocationCoordinate2D?) -> MKCoordinateRegion {
        guard let location = userLocation else {
            // Default to London if no user location
            return region(center: CLLocationCoordinate2D(latitude: 51.4014, longitude: -0.3046))
        }

        return region(center: location)
    }

    /// Create a region that encompasses a route
    static func regionForRoute(_ route: MKRoute?) -> MKCoordinateRegion? {
        guard let route = route else { return nil }
        return MKCoordinateRegion(route.polyline.boundingMapRect)
    }
}
