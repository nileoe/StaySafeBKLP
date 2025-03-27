import SwiftUI

struct ActivitiesView: View {
    private let apiService = StaySafeAPIService()
    @EnvironmentObject var userContext: UserContext

    @State private var loggedInUserActivities: [Activity] = []
    @State private var showLoggedInUserActivitiesOnly: Bool = false

    private var displayedActivities: [Activity] {
        return showLoggedInUserActivitiesOnly ? loggedInUserActivities : [] // todo
    }

    var body: some View {
        NavigationView {
            VStack {
                Toggle(isOn: $showLoggedInUserActivitiesOnly) {
                    Text("Show my trips only")
                }
                .padding(.horizontal)
                .padding(.top)

                List(displayedActivities, id: \.id) { activity in
                    NavigationLink(
                        destination: ActivityView(
                            activity: activity,
                            viewTitle: "Trip Details"
                        ),
                        label: {
                            ActivityCard(activity: activity)
                        }
                    )
                }
                .task {
                    await loadActivities()
                }
                .navigationTitle("My Trips")
            }
        }
    }

    private func loadActivities() async {
        guard let user = userContext.currentUser else {
            print("Error: No current user found.")
            return
        }

        do {
            loggedInUserActivities = try await apiService.getActivities(userID: String(user.userID))
        } catch {
            print("Unexpected error when fetching activities: \(error)")
        }
    }
}

struct ActivityCard: View {
    
    var activity: Activity
    private var departureTimeString: String {
        guard let departureLocation = activity.activityFromName else {
            return "Unknown location"
        }
        let departureTimeString = DateFormattingUtility.formatISOString(activity.activityLeave)
        return "From \(departureLocation) at \(departureTimeString)"
    }


    var body: some View {
        HStack(spacing: 12) {
            statusIndicator
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.activityName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    Text(departureTimeString)
                        .font(.caption)
                }
                
                if let fromLocation = activity.activityFromName {
                    Text(fromLocation)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(
                DateFormattingUtility.statusColor(for: activity.activityStatusName)
)
            .frame(width: 12, height: 12)
    }
}

#Preview {
    ActivitiesView()
}
