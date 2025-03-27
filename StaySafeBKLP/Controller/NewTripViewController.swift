import MapKit
import SwiftUI

class NewTripViewController: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var destinationName: String = ""
    @Published var departureDate = Date()
    @Published var transportType = TransportType.car
    @Published var isCalculatingRoute = false
    @Published var estimatedTravelTime: TimeInterval?
    @Published var estimatedArrivalTime: Date?
    @Published var hasSelectedDestination = false

    // Search properties
    @Published var searchQuery = ""
    @Published var isSearchActive = false
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private lazy var searchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.resultTypes = .pointOfInterest
        return completer
    }()

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

    override init() {
        locationManager = LocationManager()
        super.init()
        centerMapOnUserLocation()
    }

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        super.init()
        centerMapOnUserLocation()
    }

    private func centerMapOnUserLocation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, !self.hasSelectedDestination else { return }
            if let userLocation = self.locationManager.userLocation {
                self.region = MapRegionUtility.userRegion(userLocation: userLocation)
            }
        }
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query
        if !query.isEmpty && !isSearchActive { isSearchActive = true }
        searchCompleter.queryFragment = query
    }

    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
    }

    func selectSearchResult(_ result: MKLocalSearchCompletion) {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        MKLocalSearch(request: MKLocalSearch.Request(completion: result)).start {
            [weak self] response, _ in
            guard let self = self, let item = response?.mapItems.first else { return }

            DispatchQueue.main.async {
                self.selectedLocation = item.placemark.coordinate
                self.destinationName = self.formatDestinationName(result, placemark: item.placemark)
                self.region = MapRegionUtility.region(center: item.placemark.coordinate)
                self.isSearchActive = false
                self.searchQuery = ""
                self.hasSelectedDestination = true

                // Trigger calculations with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.calculateEstimatedArrival()
                    self.determineActivityStatus()
                }
            }
        }
    }

    private func formatDestinationName(_ result: MKLocalSearchCompletion, placemark: MKPlacemark)
        -> String
    {
        var name = result.title
        if name.count < 16 {
            name = "\(name), \(result.subtitle)"

            if name.count < 16, let locality = placemark.locality {
                let adminArea = placemark.administrativeArea ?? ""
                name += " in \(locality)\(adminArea.isEmpty ? "" : ", \(adminArea)")"
            }
        }
        return name
    }

    func clearSearch() {
        searchQuery = ""
        isSearchActive = false
        searchResults = []
    }

    func centerOnUserLocation() {
        if let userLocation = locationManager.userLocation {
            region = MapRegionUtility.userRegion(userLocation: userLocation)
            hasSelectedDestination = false
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

// MARK: - MKLocalSearchCompleterDelegate
extension NewTripViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}
