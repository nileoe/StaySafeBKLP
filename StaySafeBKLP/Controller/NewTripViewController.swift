import MapKit
import SwiftUI

class NewTripViewController: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.4014, longitude: -0.3046),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var destinationName: String = ""
    @Published var departureDate = Date()
    @Published var transportType = TransportType.car
    @Published var isCalculatingRoute = false
    @Published var estimatedTravelTime: TimeInterval?
    @Published var estimatedArrivalTime: Date?

    private let locationManager: LocationManager

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func centerOnUserLocation() {
        if let userLocation = locationManager.userLocation {
            region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    func calculateEstimatedArrival() {
        guard let userLocation = locationManager.userLocation,
            let destinationLocation = selectedLocation
        else {
            estimatedArrivalTime = nil
            return
        }

        isCalculatingRoute = true
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation))
        request.transportType = transportType.mapKitType

        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let route = response?.routes.first {
                    // Add slight delay to make the change visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.estimatedTravelTime = route.expectedTravelTime
                        self.estimatedArrivalTime = self.departureDate.addingTimeInterval(
                            route.expectedTravelTime)
                        self.isCalculatingRoute = false
                    }
                } else {
                    print(
                        "Error calculating directions: \(error?.localizedDescription ?? "Unknown error")"
                    )
                    self.isCalculatingRoute = false
                }
            }
        }
    }
}
