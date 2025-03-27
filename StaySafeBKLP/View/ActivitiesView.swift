import SwiftUI

struct ActivitiesView: View {
    private let apiService = StaySafeAPIService()
    @EnvironmentObject var userContext: UserContext
    
    @State private var userActivities: [Activity] = []
    @State private var contactsActivities: [Activity] = []
    @State private var contactDetails: [ContactDetail] = [] // TODO remove along with associated methods
    
    @State private var activeActivities: [Activity] = []
    @State private var plannedActivities: [Activity] = []
    @State private var completedOrCancelledActivities: [Activity] = []
    
    @State private var showContactActivities: Bool = true
    @State private var locationsByActivityIDs: [Int:Location] = [:]
    
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
                        handlePickerSelection(newValue)
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
                        showContactView: showContactActivities
                    )
                    ActivitiesSection(
                        sectionTitle: "Planned Trips",
                        activities: plannedActivities,
                        noActivitiesMessage: "No planned trips",
                        locationsByIDs: locationsByActivityIDs,
                        showContactView: showContactActivities
                    )
                    ActivitiesSection(
                        sectionTitle: "Past Trips",
                        activities: completedOrCancelledActivities,
                        noActivitiesMessage: "No past trips",
                        locationsByIDs: locationsByActivityIDs,
                        showContactView: showContactActivities
                    )
                }
                .task {
                    await loadActivities()
                    await loadContactActivities()
                    await loadLocations()
                    //                    await loadContactDetails()
                }
                .navigationTitle("My Trips")
            }
        }
    }
    
    private func handlePickerSelection(_ includeContactsActivities: Bool) {
        if includeContactsActivities {
            plannedActivities = contactsActivities.filter({ $0.isPlanned() })
            completedOrCancelledActivities = contactsActivities .filter({ $0.isCompleted() || $0.isCancelled() })
            activeActivities = contactsActivities.filter({ $0.hasStarted() || $0.isPaused() })
        } else {
            plannedActivities = userActivities.filter({ $0.isPlanned() })
            completedOrCancelledActivities = userActivities .filter({ $0.isCompleted() || $0.isCancelled() })
            activeActivities = userActivities.filter({ $0.hasStarted() || $0.isPaused() })
        }
    }
    private func loadLocations() async {
        for activity in userActivities {
            do {
                locationsByActivityIDs[activity.activityID] = try await apiService
                    .getLocation(id: String(activity.activityToID))
            } catch {
                print("Error fetching location: \(error.localizedDescription)")
            }
            for activity in contactsActivities {
                do {
                    locationsByActivityIDs[activity.activityID] = try await apiService
                        .getLocation(id: String(activity.activityToID))
                } catch {
                    print("Error fetching location: \(error.localizedDescription)")
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
            userActivities = try await apiService.getActivities(userID: String(user.userID))
        } catch {
            print("Unexpected error when fetching activities: \(error)")
        }
        plannedActivities = userActivities.filter({ $0.isPlanned() })
        completedOrCancelledActivities = userActivities .filter({ $0.isCompleted() || $0.isCancelled() })
        activeActivities = userActivities.filter({ $0.hasStarted() || $0.isPaused() })
    }
    private func loadContactDetails() async {
        guard let user = userContext.currentUser else {
            print("Error: No current user found.")
            return
        }
        
        do {
            contactDetails = try await apiService
                .getContacts(userID: String(user.userID))
        } catch {
            print("Unexpected error when fetching contacts: \(error)")
        }
        print("PRINTING LSiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
        print(contactDetails)
    }
    
    private func loadContactActivities() async {
        guard let user = userContext.currentUser else {
            print("Error: No current user found.")
            return
        }
        do {
            contactsActivities = try await apiService.getContactsActivities(
                userID: String(user.userID)
            )
            print("PRINTING CONTACT ACTIVITIES")
            for activity in contactsActivities {
                print("\(activity.activityName)")
            }
        } catch {
            print("Unexpected error when fetching activities: \(error)")
        }
    }
}

struct _ContactsTripView: View {
    let contacts: [ContactDetail]
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(contacts, id: \.id) { contact in
                Text(contact.userContactLabel)
                
                //                    UniversalActivityCard(
                //                        activity: activity,
                //                        location: locationsByIDs[activity.activityID],
                //                        displayMode: .banner,
                //                        contactName: nil,
                //                        contactImageURL: nil,
                //                        onCardTap: {},
                //                        onViewTrip: nil,
                //                        onEndTrip: nil
                //                    )
            }
        }
    }
}

struct ActivitiesSection: View {
    let sectionTitle: String
    let activities: [Activity]
    let noActivitiesMessage: String
    var locationsByIDs: [Int:Location]
    let  showContactView: Bool
    
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
                        contactName: nil,
                        contactImageURL: nil,
                        onCardTap: {},
                        onViewTrip: nil,
                        onEndTrip: nil
                    )
                    .padding(.horizontal)
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
