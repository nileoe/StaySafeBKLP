import Combine
import CoreLocation
import SwiftUI

class TripDetailsViewController: ObservableObject {
    // MARK: - Published Properties
    @Published var currentActivity: Activity
    @Published var tripPositions: [Position] = []
    @Published var isLoadingPositions = false
    @Published var isEndingTrip = false
    @Published var isPausingTrip = false
    @Published var isResumingTrip = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let apiService = StaySafeAPIService()
    private let trackingService = PositionTrackingService.shared
    private let isOwner: Bool

    // MARK: - Initialization
    init(activity: Activity, isOwner: Bool) {
        self.currentActivity = activity
        self.isOwner = isOwner

        if activity.hasStarted() && isOwner {
            trackingService.startTracking(for: activity.activityID)
        }

        loadPositionHistory()
    }

    // MARK: - Position Management
    private func loadPositionHistory() {
        guard !isLoadingPositions else { return }

        isLoadingPositions = true
        Task {
            do {
                let positions = try await trackingService.getPositionsForActivity(
                    currentActivity.activityID)
                await updateState {
                    self.tripPositions = positions.sorted {
                        $0.positionTimestamp < $1.positionTimestamp
                    }
                    self.isLoadingPositions = false
                }
            } catch {
                await updateState {
                    self.errorMessage = "Could not load tracking data"
                    self.isLoadingPositions = false
                }
            }
        }
    }

    // MARK: - Trip Actions
    func cancelTrip() async -> Bool {
        guard isOwner, !isEndingTrip else { return false }

        await updateState { isEndingTrip = true }
        do {
            var updatedActivity = currentActivity
            updatedActivity.activityStatusID = ActivityStatus.cancelled.rawValue
            updatedActivity.activityStatusName = ActivityStatus.cancelled.name

            let savedActivity = try await apiService.updateActivity(activity: updatedActivity)
            trackingService.stopTracking()

            await updateState {
                isEndingTrip = false
                notifyActivityChanged(savedActivity)
            }
            return true
        } catch {
            await updateState {
                isEndingTrip = false
                errorMessage = "Failed to end trip: \(error.localizedDescription)"
            }
            return false
        }
    }

    func pauseTrip() async -> Bool {
        guard isOwner, !isPausingTrip else { return false }

        await updateState { isPausingTrip = true }
        do {
            let updatedActivity = try await trackingService.pauseActivity(currentActivity)

            await updateState {
                isPausingTrip = false
                currentActivity = updatedActivity
                notifyActivityChanged(updatedActivity)
            }
            return true
        } catch {
            await updateState {
                isPausingTrip = false
                errorMessage = "Failed to pause trip: \(error.localizedDescription)"
            }
            return false
        }
    }

    func resumeTrip() async -> Bool {
        guard isOwner, !isResumingTrip else { return false }

        await updateState { isResumingTrip = true }
        do {
            let userId = UserContext.shared.currentUser?.userID
            guard let userId = userId else { return false }

            // Get any other active trips that might be affected by resuming
            let allActivities = try await apiService.getActivities(userID: String(userId))
            let otherActiveTrips = allActivities.filter {
                $0.hasStarted() && $0.activityID != currentActivity.activityID
            }

            let updatedActivity = try await trackingService.startActivity(currentActivity)

            await updateState {
                isResumingTrip = false
                currentActivity = updatedActivity
                notifyActivityChanged(updatedActivity)

                // Notify about other trips that were automatically modified
                otherActiveTrips.forEach(notifyActivityChanged)
            }
            return true
        } catch {
            await updateState {
                isResumingTrip = false
                errorMessage = "Failed to resume trip: \(error.localizedDescription)"
            }
            return false
        }
    }

    func startTrip() async -> Bool {
        guard isOwner, !isResumingTrip else { return false }

        await updateState { isResumingTrip = true }
        do {
            var updatedActivity = currentActivity
            updatedActivity.activityStatusID = ActivityStatus.started.rawValue
            updatedActivity.activityStatusName = ActivityStatus.started.name

            let savedActivity = try await apiService.updateActivity(activity: updatedActivity)
            trackingService.startTracking(for: savedActivity.activityID)

            await updateState {
                isResumingTrip = false
                currentActivity = savedActivity
                notifyActivityChanged(savedActivity)
            }
            return true
        } catch {
            await updateState {
                isResumingTrip = false
                errorMessage = "Failed to start trip: \(error.localizedDescription)"
            }
            return false
        }
    }

    // MARK: - Helper Methods
    private func notifyActivityChanged(_ activity: Activity) {
        NotificationCenter.default.post(
            name: Notification.Name("ActivityStatusChanged"), object: activity)
    }

    func refreshActivity() async {
        do {
            let updatedActivity = try await apiService.getActivity(
                id: String(currentActivity.activityID))

            await updateState {
                currentActivity = updatedActivity
                loadPositionHistory()
            }
        } catch {
            await updateState { errorMessage = "Error refreshing activity data" }
        }
    }

    func cleanup() {
        if isOwner && (currentActivity.hasStarted() || currentActivity.isPaused()) {
            trackingService.stopTracking()
        }
    }

    @MainActor private func updateState(_ updates: () -> Void) {
        updates()
    }
}
