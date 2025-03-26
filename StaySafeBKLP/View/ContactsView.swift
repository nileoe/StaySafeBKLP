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
                    ContactDetailView(contact: contact)
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
                                .foregroundColor(.white)      // Set the text color to white
                                .padding(5)                   // Add some internal padding
                                .background(Color.green)      // Set the background color to green
                                .cornerRadius(5)              // Optional: Add rounded corners for a nicer look
                            
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

//struct ContactDetailView: View {
//    private let apiService = StaySafeAPIService()
//    var contact: ContactDetail
//    @State var currentActivity: Activity? = nil
//    
//    var body: some View {
//        VStack {
//            ProfileDisplay(profile: contact)
//                .padding(.vertical)
//        }
//        .task {
//            await loadCurrentActivity()
//        }
//        if (contact.isTravelling()) {
//            if let activity = currentActivity {
//                ActivityView(activity: activity)
//            }
//        } else {
//            Text("No current trip to display")
//                .font(.subheadline)
//                .italic()
//        }
//    }
struct ContactDetailView: View {
    private let apiService = StaySafeAPIService()
    var contact: ContactDetail
    @State var currentActivity: Activity? = nil
    @State var isTravelling: Bool? = nil

    var body: some View {
        VStack {
            ProfileDisplay(profile: contact)
                .padding(.vertical)

            if let travelling = isTravelling {
                if travelling {
                    if let activity = currentActivity {
                        ActivityView(
                            activity: activity,
                            viewTitle: "\(contact.userFirstname)'s Current Trip"
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
            // Load the travel status asynchronously.
            self.isTravelling = await contact.isTravelling()
            
            // If the contact is travelling, attempt to load the current activity.
            if self.isTravelling == true {
                await loadCurrentActivity()
            }
        }
    }
    
    private func loadCurrentActivity() async {
        do {
            let contactActivities = try await apiService.getActivities(userID: String(contact.userID))
            let currentActivities = contactActivities.filter { $0.isCurrent() }
            
            // Set up a DateFormatter to parse the 'activityLeave' string.
            let dateFormatter = DateFormatter()
            // Adjust the date format string to match the format of 'activityLeave'.
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            // Find the current activity with the most recent (i.e. maximum) departure time.
            let mostRecentActivity = currentActivities.max { (activityA, activityB) in
                guard let dateA = dateFormatter.date(from: activityA.activityLeave),
                      let dateB = dateFormatter.date(from: activityB.activityLeave) else {
                    return false // If one date fails to parse, don't consider it less than the other.
                }
                return dateA < dateB
            }
            currentActivity = mostRecentActivity
        } catch {
            print("Error fetching activities: \(error)")
        }
    }
}
//struct ContactDisplay: View {
//    let contact: Contact
//    var body: some View {
//        VStack {
//            ProfileImage(imageURL: contact.userImageURL)
////            UserInfoSection(user: user)
//            UserInfoSection(
//                fullName: user.fullName,
//                username: user.userUsername,
//                phone: user.userPhone
//            )
//                .padding(.top, 40)
//        }
//    }
//}

#Preview {
    ContactsView()
}
