import Combine
import MapKit
import SwiftUI

class MapViewController: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.4014, longitude: -0.3046),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var followUser = false
    @Published var initialLocationSet = false
    @Published var currentTrip: TripDetails?

    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    init(locationManager: LocationManager) {
        self.locationManager = locationManager

        // Set up publisher for user location updates
        locationManager.$userLocation
            .sink { [weak self] location in
                self?.setInitialLocation(location)
            }
            .store(in: &cancellables)
    }

    func setInitialLocation(_ location: CLLocationCoordinate2D?) {
        if !initialLocationSet, let userLocation = location {
            region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            followUser = true
            initialLocationSet = true
        }
    }

    func centerOnUser() {
        if let userLocation = locationManager.userLocation {
            region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            followUser = true
        }
    }

    func createTrip(
        destination: CLLocationCoordinate2D, destinationName: String,
        transportType: MKDirectionsTransportType, departureTime: Date,
        estimatedArrival: Date?
    ) {
        guard let userLocation = locationManager.userLocation else { return }

        let newTrip = TripDetails(
            destination: destination,
            destinationName: destinationName,
            transportType: transportType,
            departureTime: departureTime,
            estimatedArrivalTime: estimatedArrival,
            route: nil
        )

        // Calculate route for display
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transportType

        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else {
                print("Error calculating route: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                var updatedTrip = newTrip
                updatedTrip.route = route
                self.currentTrip = updatedTrip
                self.region = MKCoordinateRegion(route.polyline.boundingMapRect)
            }
        }
    }
}
