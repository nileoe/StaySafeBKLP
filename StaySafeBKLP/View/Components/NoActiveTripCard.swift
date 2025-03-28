import SwiftUI

struct NoActiveTripCard: View {
    @Environment(\.colorScheme) var colorScheme
    let onCreateTrip: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            // Combined top row with icon and text
            HStack(spacing: 12) {
                // Icon on the left
                Image(systemName: "figure.walk")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .padding(8)

                // Stacked text on the right
                VStack(alignment: .leading, spacing: 4) {
                    Text("No Active Trips")
                        .font(.headline)

                    Text("Plan a trip to stay connected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 6)

            // Button remains as a separate row
            GradientActionButton(
                title: "Plan a New Trip",
                systemImage: "plus.circle.fill",
                baseColor: .blue,
                action: onCreateTrip
            )
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
    NoActiveTripCard(onCreateTrip: {}).padding()
}
