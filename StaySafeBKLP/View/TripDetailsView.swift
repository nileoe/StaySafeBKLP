import CoreLocation
import MapKit
import SwiftUI

struct TripDetailsView: View {
    // MARK: - Properties
    let activity: Activity
    let onEndTrip: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var userContext: UserContext
    @StateObject private var controller: TripDetailsViewController
    @State private var contactName: String = "Loading..."

    private var isOwner: Bool {
        userContext.currentUser?.userID == controller.currentActivity.activityUserID
    }

    // MARK: - Initialization
    init(activity: Activity, onEndTrip: @escaping () -> Void) {
        self.activity = activity
        self.onEndTrip = onEndTrip
        let isOwner = UserContext.shared.currentUser?.userID == activity.activityUserID
        self._controller = StateObject(
            wrappedValue: TripDetailsViewController(activity: activity, isOwner: isOwner))
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? UIColor(white: 0.10, alpha: 1.0) : UIColor.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        mapSection
                        infoCard

                        if isOwner {
                            actionButtons
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Trip Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } }
            }
            .disabled(
                controller.isEndingTrip || controller.isPausingTrip || controller.isResumingTrip
            )
            .onAppear {
                Task {
                    await controller.refreshActivity()
                    if !isOwner { fetchContactName() }
                }
            }
            .onDisappear { controller.cleanup() }
        }
    }

    // MARK: - Components

    // Map Section
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trip Route").font(.headline).padding(.leading)

            Group {
                if !controller.tripPositions.isEmpty {
                    TrackingMapView(
                        activity: controller.currentActivity,
                        positions: controller.tripPositions,
                        showUserLocation: isOwner
                    )
                    .frame(height: 250)
                } else if controller.isLoadingPositions {
                    loadingMapPlaceholder
                } else {
                    emptyMapPlaceholder
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 3)
        }
    }

    private var loadingMapPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .frame(height: 250)
            .overlay { ProgressView("Loading trip data...") }
    }

    private var emptyMapPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .frame(height: 250)
            .overlay {
                VStack {
                    Image(systemName: "map").font(.largeTitle).foregroundColor(.secondary)
                    Text("No tracking data available").foregroundColor(.secondary)
                }
            }
    }

    // Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !isOwner {
                InfoRow(
                    icon: "person.circle.fill", iconColor: .blue,
                    title: "Contact", value: contactName)
                Divider()
            }

            InfoRow(
                icon: "mappin.and.ellipse", iconColor: .red,
                title: "Destination",
                value: controller.currentActivity.activityToName ?? "Unknown location")
            Divider()

            InfoRow(
                icon: "clock", title: "Departure",
                value: DateFormattingUtility.formatISOString(
                    controller.currentActivity.activityLeave,
                    style: DateFormattingUtility.mediumDateTime))
            Divider()

            InfoRow(
                icon: "flag.checkered", title: "Estimated Arrival",
                value: DateFormattingUtility.formatISOString(
                    controller.currentActivity.activityArrive,
                    style: DateFormattingUtility.mediumDateTime))
            Divider()

            if let status = ActivityStatus(rawValue: controller.currentActivity.activityStatusID) {
                InfoRow(
                    icon: status.icon, iconColor: status.color,
                    title: "Status",
                    value: controller.currentActivity.activityStatusName ?? "Unknown")
            }

            if let latestPosition = controller.tripPositions.last {
                Divider()
                InfoRow(
                    icon: "location.fill", iconColor: .blue,
                    title: "Last Update",
                    value: DateFormattingUtility.formatTime(
                        Date(timeIntervalSince1970: TimeInterval(latestPosition.positionTimestamp)))
                )
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 3)
    }

    // Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            switch ActivityStatus(rawValue: controller.currentActivity.activityStatusID) {
            case .planned:
                GradientActionButton(
                    title: "Start Now", systemImage: "play.circle.fill",
                    baseColor: ActivityStatus.started.color, action: startTrip)
                GradientActionButton(
                    title: "Cancel Trip", systemImage: "xmark.circle.fill",
                    baseColor: ActivityStatus.cancelled.color, action: cancelTrip)

            case .started:
                GradientActionButton(
                    title: "Pause Trip", systemImage: "pause.circle.fill",
                    baseColor: ActivityStatus.paused.color, action: pauseTrip)
                GradientActionButton(
                    title: "End Trip", systemImage: "xmark.circle.fill",
                    baseColor: ActivityStatus.cancelled.color, action: cancelTrip)

            case .paused:
                GradientActionButton(
                    title: "Resume Trip", systemImage: "play.circle.fill",
                    baseColor: ActivityStatus.started.color, action: resumeTrip)
                GradientActionButton(
                    title: "End Trip", systemImage: "xmark.circle.fill",
                    baseColor: ActivityStatus.cancelled.color, action: cancelTrip)

            case .cancelled, .completed, .none:
                EmptyView()
            }
        }
    }

    // MARK: - Helper Methods
    private func fetchContactName() {
        Task {
            do {
                let user = try await StaySafeAPIService().getUser(
                    id: String(controller.currentActivity.activityUserID))
                await MainActor.run { contactName = user.fullName }
            } catch {
                await MainActor.run { contactName = "Trip Owner" }
            }
        }
    }

    private func cancelTrip() {
        Task {
            if await controller.cancelTrip() {
                onEndTrip()
                dismiss()
            }
        }
    }

    private func startTrip() {
        Task { if await controller.startTrip() { dismiss() } }
    }

    private func pauseTrip() {
        Task {
            if await controller.pauseTrip() {
                onEndTrip()
                dismiss()
            }
        }
    }

    private func resumeTrip() {
        Task {
            if await controller.resumeTrip() {
                onEndTrip()
                dismiss()
            }
        }
    }
}

// MARK: - Helper Views
struct InfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    init(icon: String, iconColor: Color = .primary, title: String, value: String) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text(value).font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    let sampleActivity = Activity(
        activityID: 123,
        activityName: "Walking to London Eye",
        activityUserID: 1,
        activityDescription: "Walking trip",
        activityFromID: 1,
        activityFromName: "Home",
        activityLeave: "2023-12-01T12:00:00Z",
        activityToID: 2,
        activityToName: "London Eye",
        activityArrive: "2023-12-01T13:00:00Z",
        activityStatusID: 2,
        activityStatusName: "In Progress"
    )

    TripDetailsView(
        activity: sampleActivity,
        onEndTrip: { print("Trip ended") }
    )
}
