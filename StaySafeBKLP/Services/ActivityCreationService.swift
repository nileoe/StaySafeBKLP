import CoreLocation
import Foundation
import MapKit

/// Service to handle the creation of Activity objects for the StaySafe API
class ActivityCreationService {
    private let apiService = StaySafeAPIService()

    /// Create a new activity with the provided information
    /// - Returns: The created Activity or an error
    func createActivity(
        destination: CLLocationCoordinate2D,
        destinationName: String,
        transportType: MKDirectionsTransportType,
        departureTime: Date,
        estimatedArrivalTime: Date?,
        statusID: Int = 1  // Default to Planned (1)
    ) async throws -> Activity {

        guard let currentUser = UserContext.shared.currentUser else {
            throw APIError.invalidUser
        }

        let userId = currentUser.userID

        // Get or create locations for the departure and destination
        let userLocation =
            locationManager.userLocation
            ?? CLLocationCoordinate2D(latitude: 51.4014, longitude: -0.3046)

        let currentLocationName = await LocationUtility.getMeaningfulLocationName(
            latitude: userLocation.latitude,
            longitude: userLocation.longitude
        )

        // 1. Create or get the departure location with the name
        let departureLocation = try await LocationUtility.createOrGetLocation(
            name: currentLocationName,
            coordinates: userLocation,
            description: "Starting point for the trip",
            address: "Current user location",
            isDestination: false
        )

        // 2. Create or get the destination location - First check if it exists
        let destinationLocation = try await LocationUtility.createOrGetLocation(
            name: destinationName,
            coordinates: destination,
            description: "Destination for trip",
            address: destinationName,
            isDestination: true
        )

        // Get the activity status from the ID
        let status = ActivityStatus(rawValue: statusID) ?? .planned

        // 3. Now create the activity using the location IDs
        let newActivity = Activity(
            activityID: 1,  // Will be assigned by the server
            activityName: String("Trip to \(destinationName)".prefix(60)),
            activityUserID: userId,
            activityUsername: currentUser.userUsername,  // Optional field
            activityDescription: "Trip using \(TransportType(mapKitType: transportType).rawValue)",
            activityFromID: departureLocation.locationID,
            activityFromName: departureLocation.locationName,

            activityLeave: DateFormattingUtility.formatDateForAPI(departureTime),
            activityToID: destinationLocation.locationID,
            activityToName: destinationLocation.locationName,
            activityArrive: DateFormattingUtility.formatDateForAPI(
                estimatedArrivalTime ?? departureTime.addingTimeInterval(3600)),
            activityStatusID: status.rawValue,
            activityStatusName: status.name
        )

        do {
            // Use the API service to create the activity
            let createdActivity = try await apiService.createActivity(activity: newActivity)
            return createdActivity
        } catch let apiError as APIError {
            print("API Error creating activity: \(apiError.description)")
            throw apiError
        } catch {
            print("Unexpected error creating activity: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Dependencies
    private let locationManager = LocationManager.shared
}
