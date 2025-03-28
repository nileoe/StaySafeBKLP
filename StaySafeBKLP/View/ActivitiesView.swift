import SwiftUI

struct ActivitiesView: View {
    private let apiService = StaySafeAPIService()
    @EnvironmentObject var userContext: UserContext
    
    @State private var userActivities: [Activity] = []
    @State private var contactsActivities: [Activity] = []
    @State private var contacts: [ContactDetail] = []
    
    @State private var activeActivities: [Activity] = []
    @State private var plannedActivities: [Activity] = []
    @State private var completedOrCancelledActivities: [Activity] = []
    
    @State private var showContactActivities: Bool = true
    @State private var locationsByActivityIDs: [Int:Location] = [:]
    @State private var usersByActivityIDs: [Int:User] = [:]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("Trips", selection: $showContactActivities) {
                        Text("My Contacts' Trips").tag(true)
                        Text("My Trips Only").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: showContactActivities) { newValue in // TODO depracated
                        handleTripSelection(useContactActivities: newValue)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.vertical)
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
                        noActivitiesMessage: "No active trips",
                        locationsByIDs: locationsByActivityIDs,
                        userByIDs:usersByActivityIDs,
                        showContactView: showContactActivities
                    )
                    ActivitiesSection(
                        sectionTitle: "Planned Trips",
                        activities: plannedActivities,
                        noActivitiesMessage: "No planned trips",
                        locationsByIDs: locationsByActivityIDs,
                        userByIDs:usersByActivityIDs,
                        showContactView: showContactActivities
                    )
                    ActivitiesSection(
                        sectionTitle: "Past Trips",
                        activities: completedOrCancelledActivities,
                        noActivitiesMessage: "No past trips",
                        locationsByIDs: locationsByActivityIDs,
                        userByIDs:usersByActivityIDs,
                        showContactView: showContactActivities
                    )
                }
                .task {
                    await loadData()
                }
                .navigationTitle("Trips")
            }
        }
    }
    
    private func handleTripSelection(useContactActivities: Bool) {
        let selectedActivities: [Activity] = useContactActivities ? contactsActivities : userActivities
        plannedActivities = selectedActivities.filter({ $0.isPlanned() })
            completedOrCancelledActivities = selectedActivities.filter({ $0.isCompleted() || $0.isCancelled() })
            activeActivities = selectedActivities.filter({ $0.hasStarted() || $0.isPaused() })
    }
    
    private func loadLocationsDict() async {
        do {
            for activity in userActivities {
                locationsByActivityIDs[activity.activityID] = try await apiService
                    .getLocation(id: String(activity.activityToID))
            }
            for activity in contactsActivities {
                locationsByActivityIDs[activity.activityID] = try await apiService
                    .getLocation(id: String(activity.activityToID))
            }
        }
        catch {
            print("Error fetching location: \(error.localizedDescription)")
        }
    }
    
    private func loadContactsDict() async {
        do {
            for activity in userActivities {
                usersByActivityIDs[activity.activityID] = try await apiService
                    .getUser(id: String(activity.activityUserID))
            }
            for activity in contactsActivities {
                usersByActivityIDs[activity.activityID] = try await apiService
                    .getUser(id: String(activity.activityUserID))
            }
        }
        catch {
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
        do {
            contacts = try await apiService
                .getContacts(userID: String(user.userID))
        } catch {
            print("Unexpected error when fetching contacts: \(error)")
        }
        await loadLocationsDict()
        await loadContactsDict()
        handleTripSelection(useContactActivities: true)
    }
}

struct ActivitiesSection: View {
    let sectionTitle: String
    let activities: [Activity]
    let noActivitiesMessage: String
    let locationsByIDs: [Int:Location]
    let userByIDs: [Int:User]
    let  showContactView: Bool
    @State private var selectedCard: ContactDetail? = nil

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
                    UniversalActivityCard(
                        activity: activity,
                        location: locationsByIDs[activity.activityID],
                        displayMode: showContactView ? .contact: .banner,
                        contactName: userByIDs[activity.activityID]?.fullName,
                        contactImageURL: userByIDs[activity.activityID]?.userImageURL,
                        onCardTap: {
                            print("\(activity.activityName) YOOOOOOOOOOOOOOOOOOOOOOYOOOOOOOOOOOOOOOOOOOOOOYOOOOOOOOOOOOOOOOOOOOOO")
                        },
                        onViewTrip: nil,
                        onEndTrip: nil
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    ActivitiesView()
}
