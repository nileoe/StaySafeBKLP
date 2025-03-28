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
                    ContactCard(contact: contact, onCardTap: { selectedContact = contact })
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
    let contact: ContactDetail
    let onCardTap: () -> Void
    
    @State var isTravelling: Bool? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileAvatarImage(
                profileImageUrl: contact.userImageURL,
                avatarDiameter: 40
            )
            
            VStack(alignment: .leading) {
                HStack {
                    Text(contact.fullName)
                        .font(.body)
                }
                Text(contact.userPhone)
                    .font(.caption)
            }
            Text(contact.userContactLabel)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()

            if let isTravelling {
                if (isTravelling) {
                    Text("Travelling")
                        .font(.caption).fontWeight(.medium).foregroundColor(.green)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.green.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .contentShape(Rectangle())
        
        .task {
            isTravelling = await contact.isTravelling()
        }
        .onTapGesture(perform: onCardTap)
    }
}

#Preview {
    VStack {
        ContactCard(
            contact: ContactDetail(
                userID: 123,
                userFirstname: "John",
                userLastname: "Doe",
                userPhone: "+1-234-567-890",
                userUsername: "johndoe",
                userPassword: "securepassword123",
                userLatitude: 37.7749,
                userLongitude: -122.4194,
                userTimestamp: 1672531200,
                userImageURL: "https://static.generated.photos/vue-static/face-generator/landing/wall/13.jpg",
                userContactID: 456,
                userContactLabel: "Work",
                userContactDatecreated: "2024-09-28T00:00:00.000Z"
            ),
            onCardTap: { print("Contact card clicked") }
        )
        .padding()

        ContactCard(
            contact: ContactDetail(
                userID: 124,
                userFirstname: "Jane",
                userLastname: "Smith",
                userPhone: "+1-987-654-3210",
                userUsername: "janesmith",
                userPassword: "anothersecurepassword123",
                userLatitude: 40.7128,
                userLongitude: -74.0060,
                userTimestamp: 1672531500,
                userImageURL: "https://static.generated.photos/vue-static/face-generator/landing/wall/14.jpg",
                userContactID: 457,
                userContactLabel: "Family",
                userContactDatecreated: "2023-10-12T00:00:00.000Z"
            ),
            onCardTap: { print("Jane's card clicked") }
        )
        .padding()

        ContactCard(
            contact: ContactDetail(
                userID: 125,
                userFirstname: "Alice",
                userLastname: "Brown",
                userPhone: "+44-20-7946-0958",
                userUsername: "alicebrown",
                userPassword: "yetanothersecurepassword456",
                userLatitude: 51.5074,
                userLongitude: -0.1278,
                userTimestamp: 1672531800,
                userImageURL: "https://static.generated.photos/vue-static/face-generator/landing/wall/15.jpg",
                userContactID: 458,
                userContactLabel: "Friend",
                userContactDatecreated: "2023-01-15T00:00:00.000Z"
            ),
            onCardTap: { print("Alice's card clicked") }
        )
        .padding()
    }
}

