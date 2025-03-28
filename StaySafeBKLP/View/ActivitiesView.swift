import SwiftUI

struct ActivitiesView: View {
    private let apiService = StaySafeAPIService()
    @EnvironmentObject var userContext: UserContext
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var controller: MapViewController
    @State private var showingNewTripView = false

    @State private var userActivities: [Activity] = []
    @State private var contactsActivities: [Activity] = []

    @State private var activeActivities: [Activity] = []
    @State private var plannedActivities: [Activity] = []
    @State private var completedOrCancelledActivities: [Activity] = []

    @State private var showingContactActivities: Bool = false
    @State private var locationsByActivityIDs: [Int: Location] = [:]
    @State private var usersByActivityIDs: [Int: User] = [:]

    init() {
        self._controller = StateObject(
            wrappedValue: MapViewController(locationManager: LocationManager.shared))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("Trips", selection: $showingContactActivities) {
                        Text("My Trips").tag(false)
                        Text("My Contacts' Trips").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: showingContactActivities) {
                        handleTripSelection(
                            useContactActivities: showingContactActivities
                        )
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.vertical)
                    GradientActionButton(
                        title: "Plan a New Trip",
                        systemImage: "plus.circle.fill",
                        baseColor: .blue,
                        action: { showingNewTripView = true }
                    ).padding(.horizontal)
                    ActivitiesSection(
                        sectionTitle: "Active Trips",
                        activities: activeActivities,
                        noActivitiesMessage: "No active trips",
                        locationsByIDs: locationsByActivityIDs,
                        userByIDs: usersByActivityIDs,
                        showingContactView: showingContactActivities
                    )
                    ActivitiesSection(
                        sectionTitle: "Planned Trips",
                        activities: plannedActivities,
                        noActivitiesMessage: "No planned trips",
                        locationsByIDs: locationsByActivityIDs,
                        userByIDs: usersByActivityIDs,
                        showingContactView: showingContactActivities
                    )
                    ActivitiesSection(
                        sectionTitle: "Past Trips",
                        activities: completedOrCancelledActivities,
                        noActivitiesMessage: "No past trips",
                        locationsByIDs: locationsByActivityIDs,
                        userByIDs: usersByActivityIDs,
                        showingContactView: showingContactActivities
                    )
                }
                .task {
                    await loadData()
                }
                .navigationTitle("Trips")
            }
            .sheet(isPresented: $showingNewTripView) {
                NewTripView(onActivityCreated: { activity in
                    if activity.hasStarted() {
                        controller.handleActivityCreated(activity)
                    }
                })
            }
        }
    }

    private func handleTripSelection(useContactActivities: Bool) {
        let selectedActivities: [Activity] =
            useContactActivities ? contactsActivities : userActivities
        plannedActivities = selectedActivities.filter({ $0.isPlanned() })
        completedOrCancelledActivities = selectedActivities.filter({
            $0.isCompleted() || $0.isCancelled()
        })
        activeActivities = selectedActivities.filter({ $0.hasStarted() || $0.isPaused() })
    }

    private func loadLocationsDict() async {
        do {
            for activity in userActivities {
                locationsByActivityIDs[activity.activityID] =
                    try await apiService
                    .getLocation(id: String(activity.activityToID))
            }
            for activity in contactsActivities {
                locationsByActivityIDs[activity.activityID] =
                    try await apiService
                    .getLocation(id: String(activity.activityToID))
            }
        } catch {
            print("Error fetching location: \(error.localizedDescription)")
        }
    }

    private func loadContactsDict() async {
        do {
            for activity in userActivities {
                usersByActivityIDs[activity.activityID] =
                    try await apiService
                    .getUser(id: String(activity.activityUserID))
            }
            for activity in contactsActivities {
                usersByActivityIDs[activity.activityID] =
                    try await apiService
                    .getUser(id: String(activity.activityUserID))
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }
    
    private func loadData() async {
        guard let user = userContext.currentUser else {
            print("Error: No current user found.")
            return
        }
        do {
            userActivities = try await apiService.getActivities(userID: String(user.userID))
        } catch {
            print("Unexpected error when fetching user activities: \(error)")
        }
        do {
            contactsActivities = try await apiService.getContactsActivities(
                userID: String(user.userID)
            )
        } catch {
            print("Unexpected error when fetching contacts activities: \(error)")
        }
        handleTripSelection(useContactActivities: false)
        async let _ = loadLocationsDict()
        async let _ = loadContactsDict()
        await loadLocationsDict()
        await loadContactsDict()
    }
}

struct ActivitiesSection: View {
    let sectionTitle: String
    let activities: [Activity]
    let noActivitiesMessage: String
    let locationsByIDs: [Int: Location]
    let userByIDs: [Int: User]
    let showingContactView: Bool
    @State private var selectedUser: User? = nil
    @State private var selectedActiviy: Activity? = nil

    var body: some View {
        Text(sectionTitle)
            .font(.headline)
            .padding().padding(.bottom, -10)
            .frame(maxWidth: .infinity, alignment: .leading)
        if activities.isEmpty {
            Text(noActivitiesMessage)
                .font(.callout)
                .italic()
                .foregroundColor(.gray)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(activities, id: \.id) { activity in
                    let activityUser: User? = userByIDs[activity.activityID]
                    UniversalActivityCard(
                        activity: activity,
                        location: locationsByIDs[activity.activityID],
                        displayMode: showingContactView ? .contact : .banner,
                        contactName: activityUser?.fullName,
                        contactImageURL: activityUser?.userImageURL,
                        onCardTap: {
                            selectedActiviy = activity
                        },
                        onViewTrip: nil,
                        onEndTrip: nil
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 6)
                }
            }
            .sheet(item: $selectedUser) { user in
                ProfileDetailView(profile: user)
            }
            .sheet(item: $selectedActiviy) { activity in
                TripDetailsView(activity: activity, onEndTrip: {})
            }
        }
    }
}
