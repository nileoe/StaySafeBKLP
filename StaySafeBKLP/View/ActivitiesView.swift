import SwiftUI

struct ActivitiesView: View {
    private let apiService = StaySafeAPIService()
    @EnvironmentObject var userContext: UserContext
    
    @State private var loggedInUserActivities: [Activity] = []
    @State private var activeActivities: [Activity] = []
    @State private var plannedActivities: [Activity] = []
    @State private var completedOrCancelledActivities: [Activity] = []
    @State private var showLoggedInUserActivitiesOnly: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("Trips", selection: $showLoggedInUserActivitiesOnly) {
                        Text("My Trips").tag(true)
                        Text("My Contact's Trips").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)
                    WideRectangleIconButton(
                        text: "Plan a new Trip",
                        backgroundColor: .blue,
                        foregroundColor: .white,
                        action: {print("ok")},
                        imageName: "plus"
                    )
                    
                    ActivitiesSection(
                        sectionTitle: "Active Trips",
                        activities: activeActivities,
                        noActivitiesMessage: "No active trips"
                    )
                    ActivitiesSection(
                        sectionTitle: "Planned Trips",
                        activities: plannedActivities,
                        noActivitiesMessage: "No planned trips"
                    )
                    ActivitiesSection(
                        sectionTitle: "Past Trips",
                        activities: completedOrCancelledActivities,
                        noActivitiesMessage: "No past trips"
                    )
                    .task {
                        await loadActivities()
                    }
                    .navigationTitle("My Trips")
                }
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
        plannedActivities = loggedInUserActivities.filter({ $0.isPlanned() })
        completedOrCancelledActivities = loggedInUserActivities .filter({ $0.isCompleted() || $0.isCancelled() })
        activeActivities = loggedInUserActivities.filter({ $0.hasStarted() || $0.isPaused() })
    }
}

struct ActivitiesSection: View {
    let sectionTitle: String
    let activities: [Activity]
    let noActivitiesMessage: String
    var body: some View {
        Text(sectionTitle)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        if (activities.isEmpty) {
            Text(noActivitiesMessage)
                .font(.callout)
                .italic()
                .foregroundColor(.gray)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(activities, id: \.id) { activity in
                    NavigationLink {
                        ActivityView(
                            activity: activity,
                            viewTitle: "Trip Details"
                        )
                    } label: {
                        ActivityCard(activity: activity)
                    }
                }
            }
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
