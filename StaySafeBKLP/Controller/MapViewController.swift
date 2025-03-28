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
            .sink { [weak self] location in self?.setInitialLocation(location) }
            .store(in: &cancellables)
    }

    func setInitialLocation(_ location: CLLocationCoordinate2D?) {
        guard !initialLocationSet, let userLocation = location else { return }
        region = MapRegionUtility.userRegion(userLocation: userLocation)
        followUser = true
        initialLocationSet = true
    }

    func centerOnUser() {
        guard let userLocation = locationManager.userLocation else { return }
        region = MapRegionUtility.userRegion(userLocation: userLocation)
        followUser = true
    }

    // MARK: - Activity & Route Management
    func handleActivityCreated(_ activity: Activity) {
        guard let userLocation = locationManager.userLocation else { return }

        Task { @MainActor in
            self.currentActivity = activity

            do {
                let location = try await apiService.getLocation(id: String(activity.activityToID))
                let destinationCoords = CLLocationCoordinate2D(
                    latitude: location.locationLatitude,
                    longitude: location.locationLongitude
                )

                self.destinationCoordinate = destinationCoords
                self.createRouteToDestination(
                    from: userLocation, to: destinationCoords, activity: activity)
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

        RouteService.calculateRoute(from: source, to: destination, transportType: transportType) {
            [weak self] result in
            guard let self = self else { return }

            if case .success(let route) = result {
                Task { @MainActor in
                    self.currentRoute = route
                    self.destinationCoordinate = destination

                    // Set the map region to show the route
                    self.region = MapRegionUtility.regionForRoute(route) ?? self.region
                }
            }
        }
    }

    func clearCurrentTrip() {
        currentActivity = nil
        currentRoute = nil
        destinationCoordinate = nil
    }

    func handleActivityStateChange(_ activity: Activity) {
        // Only process if this activity is relevant to current state
        guard currentActivity == nil || activity.activityID == currentActivity?.activityID else {
            return
        }

        Task { @MainActor in
            self.currentActivity = activity

            if activity.hasStarted() {
                if let userLocation = locationManager.userLocation,
                    let destCoord = destinationCoordinate
                {
                    createRouteToDestination(from: userLocation, to: destCoord, activity: activity)
                } else {
                    await fetchDestinationCoordinates(for: activity)
                }
            } else if activity.isPaused() {
                self.currentRoute = nil
            } else if activity.isCompleted() || activity.isCancelled() {
                clearCurrentTrip()
            }
        }
    }

    func fetchDestinationCoordinates(for activity: Activity) async {
        do {
            let location = try await apiService.getLocation(id: String(activity.activityToID))
            let destCoords = CLLocationCoordinate2D(
                latitude: location.locationLatitude,
                longitude: location.locationLongitude
            )

            await MainActor.run {
                self.destinationCoordinate = destCoords

                if let userLocation = self.locationManager.userLocation, activity.hasStarted() {
                    self.createRouteToDestination(
                        from: userLocation, to: destCoords, activity: activity)
                }
            }
        } catch {

        }
    }

    func checkForActiveTrip() {
        guard let currentUserID = UserContext.shared.currentUser?.userID else { return }

        Task {
            do {
                let activities = try await apiService.getActivities(userID: String(currentUserID))
                if let activeTrip = activities.first(where: { $0.isCurrent() }) {
                    await MainActor.run { handleActivityCreated(activeTrip) }
                }
            } catch {
                print("Error fetching active trips: \(error.localizedDescription)")
            }
        }
    }
}
