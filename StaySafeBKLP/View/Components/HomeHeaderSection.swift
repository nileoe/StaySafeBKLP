import SwiftUI

struct HomeHeaderSection: View {
    @EnvironmentObject var userContext: UserContext
    @Environment(\.colorScheme) var colorScheme

    let hasActiveTrip: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Logo and App Name
                HStack(spacing: 10) {
                    // Logo
                    StaySafeLogo(size: 30, shadowRadius: 2, shadowOpacity: 0.05)

                    // App Name
                    Text("StaySafe")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                // Active Trip Indicator: Active or Not Active
                Text(hasActiveTrip ? "Active Trip" : "No Active Trip")
                    .font(.caption).fontWeight(.medium).foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(
                        hasActiveTrip
                            ? ActivityStatus.started.color : ActivityStatus.completed.color
                    )
                    .clipShape(Capsule())
            }

            // Bottom row: User greeting
            Text(
                userContext.currentUser.map { "Hello, \($0.userFirstname)" }
                    ?? "Welcome to StaySafe"
            )
            .font(userContext.currentUser != nil ? .title : .title2)
            .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20).padding(.bottom, 10)
    }
}

#Preview {
    HomeHeaderSection(hasActiveTrip: true)
        .environmentObject(UserContext())
}
