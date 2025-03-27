import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userContext: UserContext

    @State private var activities: [Activity] = []
    @State private var locationData: [Int: Location] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showingNewTripView = false
    @State private var selectedActivity: Activity? = nil

    private var hasActiveTrip: Bool {
        activities.contains { $0.activityStatusID == ActivityStatus.started.rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    HomeHeaderSection(hasActiveTrip: hasActiveTrip)

                    // Trip card using components
                    if let activeTrip = activities.first(where: {
                        $0.activityStatusID == ActivityStatus.started.rawValue
                    }) {
                        ActiveTripCard(
                            trip: activeTrip,
                            location: locationData[activeTrip.activityToID],
                            onViewTrip: { selectedActivity = activeTrip }
                        )
                        .task {
                            if locationData[activeTrip.activityToID] == nil {
                                await fetchLocationForActivity(activeTrip)
                            }
                        }
                    } else {
                        NoActiveTripCard(onCreateTrip: { showingNewTripView = true })
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { await loadActivities() }
            .task { await loadActivities() }
            .onAppear { loadActivitiesIfNeeded() }
            .sheet(isPresented: $showingNewTripView) {
                NewTripView(onActivityCreated: { _ in loadActivitiesIfNeeded() })
            }
            .sheet(item: $selectedActivity) { activity in
                TripDetailsView(
                    activity: activity,
                    onEndTrip: {
                        Task {
                            await MainActor.run {
                                activities = activities.filter {
                                    $0.activityID != activity.activityID
                                }
                            }
                            await loadActivities()
                        }
                    }
                )
            }
            .overlay { isLoading && activities.isEmpty ? loadingOverlay : nil }
        }
        .onDisappear {
            if selectedActivity != nil { Task { await loadActivities() } }
        }
    }

    // MARK: - UI Components

    private var loadingOverlay: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.1))
    }

    // MARK: - Data loading

    private func loadActivitiesIfNeeded() { Task { await loadActivities() } }

    private func loadActivities() async {
        guard let user = userContext.currentUser else { return }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let fetchedActivities = try await StaySafeAPIService().getActivities(
                userID: String(user.userID))

            let sortedActivities = fetchedActivities.sorted {
                (DateFormattingUtility.iso8601WithMilliseconds.date(from: $0.activityLeave)
                    ?? .distantPast)
                    > (DateFormattingUtility.iso8601WithMilliseconds.date(from: $1.activityLeave)
                        ?? .distantPast)
            }

            await MainActor.run {
                activities = sortedActivities
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load activities: \(error.localizedDescription)"
                isLoading = false
                print("Error loading activities: \(error)")
            }
        }
    }

    private func fetchLocationForActivity(_ activity: Activity) async {
        do {
            let location = try await StaySafeAPIService().getLocation(
                id: String(activity.activityToID))

            await MainActor.run {
                locationData[activity.activityToID] = location
            }
        } catch {
            print("Error fetching location: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(UserContext())
}
