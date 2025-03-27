import SwiftUI

struct ActiveTripCard: View {
    @Environment(\.colorScheme) var colorScheme
    let trip: Activity
    let location: Location?
    let onViewTrip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Title row
            HStack {
                Text("Active Trip").font(.title2).fontWeight(.bold)
                Spacer()

                // Status pill
                let isPaused = trip.activityStatusID == ActivityStatus.paused.rawValue
                let status = isPaused ? ActivityStatus.paused : ActivityStatus.started
                Text(isPaused ? "Paused" : "On Route")
                    .font(.caption).fontWeight(.medium).foregroundColor(status.color)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(status.color.opacity(0.2))
                    .clipShape(Capsule())
            }

            // Location details row
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(location?.locationName ?? trip.activityToName ?? "Unknown location")
                        .font(.title3).fontWeight(.bold)

                    Text(location?.locationDescription ?? "Address loading...")
                        .font(.subheadline).lineLimit(1)

                    Text(
                        "Estimated Arrival: \(DateFormattingUtility.formatISOString(trip.activityArrive, style: DateFormattingUtility.timeOnly))"
                    )
                    .font(.subheadline).foregroundColor(.secondary)
                }

                Spacer()

                // View Trip text link
                Text("View Trip")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.blue)
                    .padding(.bottom, 2).padding(.horizontal, 8)
                    .onTapGesture(perform: onViewTrip)
            }
            .alignmentGuide(.bottom) { $0[.bottom] }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(
            color: Color.primary.opacity(colorScheme == .dark ? 0.3 : 0.05),
            radius: 5, x: 0, y: 2
        )
    }
}

#Preview {
    ActiveTripCard(
        trip: Activity(
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
        ),
        location: nil,
        onViewTrip: {}
    ).padding()
}
