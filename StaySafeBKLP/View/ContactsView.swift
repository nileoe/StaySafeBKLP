import SwiftUI

struct ContactsView: View {
    private let apiService = StaySafeAPIService()
    @EnvironmentObject var userContext: UserContext
    @State private var contacts: [ContactDetail] = []
    @State private var selectedContact: ContactDetail? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                List(contacts, id: \.id) {contact in
                    ContactCard(contact: contact)
                        .onTapGesture {
                            selectedContact = contact
                        }
                }
                .task {
                    await loadContacts()
                }
            }
            .navigationTitle("Contacts")
        }
        .sheet(item: $selectedContact) { contact in
                    ProfileDetailView(profile: contact)
                }
    }
    
    private func loadContacts() async {
        guard let user = userContext.currentUser else {
            print("Error: no current user found")
            return
        }
        do {
            contacts = try await apiService.getContacts(userID: String(user.userID))
        } catch {
            print("Unexpected error when fetching contacts: \(error)")
        }
    }
}


struct ContactCard: View {
    
    var contact: ContactDetail
    @State var isTravelling: Bool? = nil

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.fullName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.green)
                        Text(contact.userContactLabel)
                            .font(.caption)
                    }
                    Spacer()
                    if let isTravelling {
                        if (isTravelling) {
                            Text("Currently travelling")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.green)
                                .cornerRadius(5)
                            
                        }
                    }
                }
                .task {
                    isTravelling = await contact.isTravelling()
                }
            }
            
            Spacer()
            
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ProfileDetailView<Profile: ProfileDisplayable>: View {
    private let apiService = StaySafeAPIService()
//    let contact: ContactDetail
    let profile: Profile
    @State var currentActivity: Activity? = nil
    @State var isTravelling: Bool? = nil

    var body: some View {
        VStack {
            ProfileDisplay(profile: profile)
                .padding(.vertical)

            if let travelling = isTravelling {
                if travelling {
                    if let activity = currentActivity {
                        ActivityView(
                            activity: activity,
                            viewTitle: "\(profile.userFirstname)'s Current Trip"
                        )
                    } else {
                        Text("Loading current trip...")
                    }
                } else {
                    Text("No current trip to display")
                        .font(.subheadline)
                        .italic()
                }
            } else {
                Text("Checking travel status...")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            self.isTravelling = await profile.isTravelling()
            
            // If the contact is travelling attempt to load the current activity.
            if self.isTravelling == true {
                await loadCurrentActivity()
            }
        }
    }
    
    private func loadCurrentActivity() async {
        do {
            let contactActivities = try await apiService.getActivities(userID: String(profile.userID))
            let currentActivities = contactActivities.filter { $0.isCurrent() }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            // Find the current activity with the most recent (i.e. maximum) departure time.
            let mostRecentActivity = currentActivities.max { (activityA, activityB) in
                guard let dateA = dateFormatter.date(from: activityA.activityLeave),
                      let dateB = dateFormatter.date(from: activityB.activityLeave) else {
                    return false // If one date fails to parse => don't consider it for sorting
                }
                return dateA < dateB
            }
            currentActivity = mostRecentActivity
        } catch {
            print("Error fetching activities: \(error)")
        }
    }
}

#Preview {
    ContactsView()
}
