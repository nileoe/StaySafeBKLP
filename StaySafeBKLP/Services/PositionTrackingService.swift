import Combine
import CoreLocation
import Foundation
import MapKit
import SwiftUI

class PositionTrackingService: ObservableObject {
    static let shared = PositionTrackingService()

    // MARK: - Properties
    private let apiService = StaySafeAPIService()
    private let locationManager = LocationManager.shared
    private var trackingTimer: Timer?
    private var currentActivityID: Int?
    private var currentActivity: Activity?
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var lastRecordedLocation: CLLocation?
    private let minimumMovementThreshold: CLLocationDistance = 100.0

    @Published var isTracking = false
    @Published var latestPosition: Position?
    @Published var trackingError: String?

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods
    func startTracking(for activityID: Int) {
        currentActivityID = activityID
        isTracking = true
        trackingError = nil
        lastRecordedLocation = nil

        // Fetch activity details and set up destination
        Task {
            await loadActivityAndDestination(activityID)
            startBackgroundLocationUpdates()
            checkAndRecordCurrentPosition(forceRecord: true)
        }

        // Set up tracking timer (every 30 seconds)
        trackingTimer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in
            self?.checkAndRecordCurrentPosition()
        }
    }

    func stopTracking() {
        trackingTimer?.invalidate()
        trackingTimer = nil
        currentActivityID = nil
        isTracking = false
        lastRecordedLocation = nil
        endBackgroundTask()
    }

    func getPositionsForActivity(_ activityID: Int) async throws -> [Position] {
        return try await apiService.getPositions(activityID: String(activityID))
    }

    // MARK: - Private Methods
    private func loadActivityAndDestination(_ activityID: Int) async {
        do {
            let activity = try await apiService.getActivity(id: String(activityID))
            let destination = try await apiService.getLocation(id: String(activity.activityToID))

            await MainActor.run {
                self.currentActivity = activity
                self.destinationCoordinate = CLLocationCoordinate2D(
                    latitude: destination.locationLatitude,
                    longitude: destination.locationLongitude
                )
            }
        } catch {
            await MainActor.run { self.trackingError = "Failed to load activity details" }
        }
    }

    private func checkAndRecordCurrentPosition(forceRecord: Bool = false) {
        guard let activityID = currentActivityID,
            let currentLocation = locationManager.manager.location
        else {
            trackingError = "Unable to obtain current location"
            return
        }

        // Only record if forced or significant movement
        if forceRecord || hasMovedSignificantly(currentLocation) {
            recordPosition(activityID: activityID, location: currentLocation)
        } else {
            // Still update ETA even without recording position
            Task { await updateEstimatedArrival(currentLocation: currentLocation) }
        }
    }

    private func hasMovedSignificantly(_ currentLocation: CLLocation) -> Bool {
        guard let lastLocation = lastRecordedLocation else { return true }
        return currentLocation.distance(from: lastLocation) > minimumMovementThreshold
    }

    private func recordPosition(activityID: Int, location: CLLocation) {
        let position = Position(
            positionID: 1,
            positionActivityID: activityID,
            positionActivityName: nil,
            positionLatitude: location.coordinate.latitude,
            positionLongitude: location.coordinate.longitude,
            positionTimestamp: Int(Date().timeIntervalSince1970)
        )

        // Update local state
        lastRecordedLocation = location
        latestPosition = position

        // Send to API
        Task {
            do {
                _ = try await apiService.createPosition(position: position)
                await updateEstimatedArrival(currentLocation: location)
            } catch {
                await MainActor.run {
                    self.trackingError = "Failed to record position"
                }
            }
        }
    }

    private func updateEstimatedArrival(currentLocation: CLLocation) async {
        guard let activity = currentActivity,
            let destinationCoord = destinationCoordinate
        else { return }

        // Skip update if very close to destination
        let distanceToDestination = currentLocation.distance(
            from: CLLocation(
                latitude: destinationCoord.latitude,
                longitude: destinationCoord.longitude
            ))
        if distanceToDestination < 100 { return }

        // Calculate route and update ETA
        await withCheckedContinuation { continuation in
            let transportType = RouteService.getTransportTypeFromDescription(
                activity.activityDescription)

            RouteService.calculateRoute(
                from: currentLocation.coordinate,
                to: destinationCoord,
                transportType: transportType
            ) { [weak self] result in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                if case .success(let route) = result {
                    self.updateActivityETA(
                        activity: activity, newTravelTime: route.expectedTravelTime)
                }

                continuation.resume()
            }
        }
    }

    private func updateActivityETA(activity: Activity, newTravelTime: TimeInterval) {
        // Calculate new arrival time
        let newArrivalTime = Date().addingTimeInterval(newTravelTime)
        let formattedArrivalTime = DateFormattingUtility.formatDateForAPI(newArrivalTime)

        // Check if significantly different from current ETA
        guard
            let originalArrivalDate = DateFormattingUtility.iso8601WithMilliseconds.date(
                from: activity.activityArrive)
        else { return }

        let timeDifference = abs(originalArrivalDate.timeIntervalSince(newArrivalTime))
        if timeDifference < 60 { return }  // Less than 1 minute difference

        // Update activity
        Task {
            var updatedActivity = activity
            updatedActivity.activityArrive = formattedArrivalTime

            do {
                let savedActivity = try await apiService.updateActivity(activity: updatedActivity)
                await MainActor.run { self.currentActivity = savedActivity }
            } catch {
            }
        }
    }

    // MARK: - Background Task Management
    private func startBackgroundLocationUpdates() {
        locationManager.manager.allowsBackgroundLocationUpdates = true
        locationManager.manager.pausesLocationUpdatesAutomatically = false

        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func startActivity(_ activity: Activity) async throws -> Activity {
        let result = try await updateActivityStatus(activity, to: .started)
        startTracking(for: result.activityID)
        return result
    }

    func pauseActivity(_ activity: Activity) async throws -> Activity {
        let result = try await updateActivityStatus(activity, to: .paused)
        stopTracking()
        return result
    }

    func cancelActivity(_ activity: Activity) async throws -> Activity {
        let result = try await updateActivityStatus(activity, to: .cancelled)
        stopTracking()
        return result
    }

    private func updateActivityStatus(_ activity: Activity, to status: ActivityStatus) async throws
        -> Activity
    {
        var updatedActivity = activity
        updatedActivity.activityStatusID = status.rawValue
        updatedActivity.activityStatusName = status.name
        return try await apiService.updateActivity(activity: updatedActivity)
    }
}
