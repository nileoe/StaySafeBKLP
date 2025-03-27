import Combine
import MapKit
import SwiftUI

class MapViewController: ObservableObject {
    @Published var region = MapRegionUtility.region(
        center: CLLocationCoordinate2D(latitude: 51.4014, longitude: -0.3046)
    )
    @Published var followUser = false
    @Published var initialLocationSet = false
    @Published var currentActivity: Activity?
    @Published var currentRoute: MKRoute?
    @Published var destinationCoordinate: CLLocationCoordinate2D?
    let apiService = StaySafeAPIService()

    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()

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
            region = MapRegionUtility.userRegion(userLocation: userLocation)
            followUser = true
            initialLocationSet = true
        }
    }

    func centerOnUser() {
        if let userLocation = locationManager.userLocation {
            region = MapRegionUtility.userRegion(userLocation: userLocation)
            followUser = true
        }
    }

    func handleActivityCreated(_ activity: Activity) {
        guard let userLocation = locationManager.userLocation else { return }

        // Store the created activity on the main thread
        DispatchQueue.main.async {
            self.currentActivity = activity
        }

        // Fetch destination location coordinates from the API
        Task { @MainActor in
            do {
                // Get the destination location details using the activityToID from the activity
                let location = try await apiService.getLocation(id: String(activity.activityToID))

                let destinationCoordinates = CLLocationCoordinate2D(
                    latitude: location.locationLatitude,
                    longitude: location.locationLongitude
                )

                // Since we're using @MainActor, these UI updates are automatically on the main thread
                self.destinationCoordinate = destinationCoordinates

                self.createRouteToDestination(
                    from: userLocation,
                    to: destinationCoordinates,
                    activity: activity
                )
            } catch {

            }
        }
    }

    private func createRouteToDestination(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        activity: Activity
    ) {

        let transportType = RouteService.getTransportTypeFromDescription(
            activity.activityDescription)

        RouteService.calculateRoute(
            from: source,
            to: destination,
            transportType: transportType
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let route):
                DispatchQueue.main.async {
                    // Store the route separately
                    self.currentRoute = route
                    self.destinationCoordinate = destination

                    // Set the map region to show the route
                    self.region = MapRegionUtility.regionForRoute(route) ?? self.region
                }

            case .failure(let error):
                print("Error calculating route: \(error.localizedDescription)")
            }
        }
    }

    func clearCurrentTrip() {
        currentActivity = nil
        currentRoute = nil
        destinationCoordinate = nil
    }

    func checkForActiveTrip() {
        guard let currentUserID = UserContext.shared.currentUser?.userID else { return }

        Task { @MainActor in
            do {
                let activities = try await apiService.getActivities(userID: String(currentUserID))
                activities.first(where: { $0.activityStatusID == 2 }).map(handleActivityCreated)
            } catch {
                print("Error fetching active trips: \(error.localizedDescription)")
            }
        }
    }
}
