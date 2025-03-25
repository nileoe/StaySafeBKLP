import MapKit
import SwiftUI

class NewTripViewController: ObservableObject {
    @Published var region = MapRegionUtility.region(
        center: CLLocationCoordinate2D(latitude: 51.4014, longitude: -0.3046)
    )
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var destinationName: String = ""
    @Published var departureDate = Date()
    @Published var transportType = TransportType.car
    @Published var isCalculatingRoute = false
    @Published var estimatedTravelTime: TimeInterval?
    @Published var estimatedArrivalTime: Date?

    // API interaction states
    @Published var isCreatingActivity = false
    @Published var creationError: Error?
    @Published var createdActivity: Activity?

    // Activity status properties
    @Published var activityStatus: ActivityStatus = .planned {
        didSet {
            activityStatusID = activityStatus.rawValue
        }
    }
    @Published var activityStatusID: Int = ActivityStatus.planned.rawValue
    @Published var isDepartureValid: Bool = true
    @Published var departureValidationMessage: String = ""

    private let locationManager: LocationManager
    private let activityService = ActivityCreationService()

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func centerOnUserLocation() {
        if let userLocation = locationManager.userLocation {
            region = MapRegionUtility.userRegion(userLocation: userLocation)
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

        RouteService.calculateRoute(
            from: userLocation,
            to: destinationLocation,
            transportType: transportType
        ) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let route):
                    // Slight delay to make the change visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.estimatedTravelTime = route.expectedTravelTime
                        self.estimatedArrivalTime = self.departureDate.addingTimeInterval(
                            route.expectedTravelTime)
                        self.isCalculatingRoute = false
                    }

                case .failure(let error):
                    print("Error calculating directions: \(error.localizedDescription)")
                    self.isCalculatingRoute = false
                }
            }
        }

        determineActivityStatus()
    }

    func determineActivityStatus() {
        let now = Date()
        let fiveMinutesFromNow = now.addingTimeInterval(5 * 60)  // 5 minutes in seconds

        // Add a 1-minute buffer for "now" times
        let oneMinuteAgo = now.addingTimeInterval(-60)

        if departureDate < oneMinuteAgo {
            isDepartureValid = false
            departureValidationMessage = "Departure time cannot be in the past."
            activityStatus = .planned  // Default to Planned even if invalid
        }
        // Check if departure time is now or within next 5 minutes
        else if departureDate <= fiveMinutesFromNow {
            isDepartureValid = true
            departureValidationMessage = ""
            activityStatus = .started
        }
        // Departure time is more than 5 minutes in the future
        else {
            isDepartureValid = true
            departureValidationMessage = ""
            activityStatus = .planned
        }
    }

    func onDepartureDateChanged() {
        calculateEstimatedArrival()
        determineActivityStatus()
    }

    @MainActor
    func createActivity() async {
        guard let destinationCoordinate = selectedLocation else { return }

        // Verify departure time is valid - same buffer as in determineActivityStatus
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        if departureDate < oneMinuteAgo {
            // Update error to show invalid departure time
            creationError = NSError(
                domain: "com.staysafe.validation",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Departure time cannot be in the past."]
            )
            return
        }

        isCreatingActivity = true
        creationError = nil
        createdActivity = nil  // Reset any previous activity

        do {
            let activity = try await activityService.createActivity(
                destination: destinationCoordinate,
                destinationName: destinationName.isEmpty ? "Unknown location" : destinationName,
                transportType: transportType.mapKitType,
                departureTime: departureDate,
                estimatedArrivalTime: estimatedArrivalTime,
                statusID: activityStatus.rawValue
            )

            self.createdActivity = activity
        } catch let apiError as APIError {
            self.creationError = apiError
            print("API Error creating activity: \(apiError.description)")
        } catch {
            self.creationError = error
            print("Error creating activity: \(error.localizedDescription)")
        }

        isCreatingActivity = false
    }
}
