import SwiftUI

struct UniversalActivityCard: View {
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Required Parameters
    let activity: Activity
    let location: Location?
    let displayMode: ActivityCardDisplayMode

    // MARK: - Optional Parameters
    let contactName: String?
    let contactImageURL: String?
    let onCardTap: () -> Void
    let onViewTrip: (() -> Void)?
    let onEndTrip: (() -> Void)?

    // MARK: - Computed Properties
    private var activityStatus: ActivityStatus {
        ActivityStatus(rawValue: activity.activityStatusID) ?? .planned
    }

    private var locationName: String {
        location?.locationName ?? activity.activityToName ?? "Unknown location"
    }

    private var locationDescription: String {
        location?.locationDescription ?? location?.locationAddress ?? "Address unavailable"
    }

    private var estimatedArrival: String {
        "Estimated Arrival: \(DateFormattingUtility.formatISOString(activity.activityArrive, style: DateFormattingUtility.timeOnly))"
    }

    private var timeDisplayText: String {
        // For active trips, show estimated arrival
        if activityStatus == .started || activityStatus == .paused { return estimatedArrival }

        // For non-active trips, show date range
        let leaveDate =
            DateFormattingUtility.iso8601WithMilliseconds.date(from: activity.activityLeave)
            ?? Date()
        let arriveDate =
            DateFormattingUtility.iso8601WithMilliseconds.date(from: activity.activityArrive)
            ?? Date()

        // Format based on whether dates are on same day
        let isSameDay = Calendar.current.isDate(leaveDate, inSameDayAs: arriveDate)

        return isSameDay
            ? "\(DateFormattingUtility.formatDate(leaveDate, style: .medium, includeTime: false)), \(DateFormattingUtility.formatTime(leaveDate)) - \(DateFormattingUtility.formatTime(arriveDate))"
            : "\(DateFormattingUtility.formatDate(leaveDate, style: .medium, includeTime: true)) - \(DateFormattingUtility.formatDate(arriveDate, style: .medium, includeTime: true))"
    }

    private var cardBackgroundColor: Color {
        Color(.secondarySystemGroupedBackground)
    }

    // MARK: - View Config Properties

    private var showsHeader: Bool { displayMode == .home }
    private var locationNameFont: Font { displayMode == .home ? .title3 : .headline }
    private var timeFont: Font { displayMode == .home ? .subheadline : .caption }
    private var timeText: String { displayMode == .home ? estimatedArrival : timeDisplayText }
    private var actionButtonText: String {
        displayMode == .contact && activityStatus.isActive ? "Track" : "View Trip"
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if displayMode == .home {
                headerRow
            } else if displayMode == .contact {
                contactHeader

                Divider()
            }

            // Unified details row with ZStack for banner style status pill
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .bottom, spacing: 10) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(locationName)
                            .font(locationNameFont).fontWeight(.bold)
                            .padding(.trailing, displayMode == .banner ? 70 : 0)

                        Text(locationDescription)
                            .font(.subheadline).lineLimit(1)

                        Text(timeText)
                            .font(timeFont).foregroundColor(.secondary)
                    }

                    Spacer()

                    if let onViewTrip = onViewTrip {
                        Text(actionButtonText)
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.blue)
                            .padding(.bottom, 2).padding(.horizontal, 8)
                            .onTapGesture(perform: onViewTrip)
                    }
                }

                // Only show status pill at top right for banner style
                if displayMode == .banner {
                    statusPill
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(15)
        .shadow(
            color: Color.primary.opacity(colorScheme == .dark ? 0.3 : 0.05),
            radius: 5, x: 0, y: 2
        )
        .onTapGesture(perform: onCardTap)
    }

    // MARK: - Reusable Components

    // Header row - used for home style
    private var headerRow: some View {
        HStack {
            Text("Active Trip").font(.title2).fontWeight(.bold)
            Spacer()
            statusPill
        }
    }

    // Contact header - used for contact style
    private var contactHeader: some View {
        HStack(spacing: 12) {
            ProfileAvatarImage(
                profileImageUrl: contactImageURL, avatarDiameter: 36
            )
            Text("\(contactName ?? "Someone")'s Trip")
                .font(.headline)

            Spacer()

            statusPill
        }
    }

    // Status pill - used in multiple places
    private var statusPill: some View {
        Text(activityStatusText)
            .font(.caption).fontWeight(.medium).foregroundColor(activityStatus.color)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(activityStatus.color.opacity(0.2))
            .clipShape(Capsule())
    }

    private var activityStatusText: String {
        switch activityStatus {
        case .started:
            return "On Route"
        case .paused:
            return "Paused"
        case .planned:
            return "Planned"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
}

// MARK: - Preview

private let previewActivity = Activity(
    activityID: 1,
    activityName: "Trip to London",
    activityUserID: 1,
    activityDescription: "Going to London",
    activityFromID: 1,
    activityLeave: "2023-12-01T10:00:00Z",
    activityToID: 2,
    activityToName: "London",
    activityArrive: "2023-12-01T12:00:00Z",
    activityStatusID: 2,
    activityStatusName: "Started"
)

#Preview("Home Style") {
    UniversalActivityCard(
        activity: previewActivity,
        location: nil,
        displayMode: .home,
        contactName: nil,
        contactImageURL: nil,
        onCardTap: {},
        onViewTrip: {},
        onEndTrip: nil
    )
    .padding()
}

#Preview("Banner Style") {
    UniversalActivityCard(
        activity: previewActivity,
        location: nil,
        displayMode: .banner,
        contactName: nil,
        contactImageURL: nil,
        onCardTap: {},
        onViewTrip: {},
        onEndTrip: nil
    )
    .padding()
}

#Preview("Contact Style") {
    UniversalActivityCard(
        activity: previewActivity,
        location: nil,
        displayMode: .contact,
        contactName: "Sarah",
        contactImageURL: nil,
        onCardTap: {},
        onViewTrip: {},
        onEndTrip: nil
    )
    .padding()
}
