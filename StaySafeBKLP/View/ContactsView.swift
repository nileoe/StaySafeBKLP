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
    
    var body: some View {
        HStack(spacing: 12){
            AvatarImageView(
                profileImageUrl: contact.userImageURL,
                avatarDiameter: 50
            )
            
            Text(contact.fullName)
                .font(.headline)
            //            statusPill
            Spacer()
            
        }
        .onTapGesture(perform: onCardTap) // TODO rectangle
    }
}

//private var statusPill: some View {
//    Text(activityStatusText)
//        .font(.caption).fontWeight(.medium).foregroundColor(activityStatus.color)
//        .padding(.horizontal, 12).padding(.vertical, 6)
//        .background(activityStatus.color.opacity(0.2))
//        .clipShape(Capsule())
//}

struct OLD_ContactCard: View {
    
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

struct AvatarImageView: View {
    let profileImageUrl: String?
    let avatarDiameter: CGFloat
    var body: some View {
        if let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty {
            AsyncImage(url: URL(string: profileImageUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: avatarDiameter, height: avatarDiameter)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.fill")
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.gray)
                .clipShape(Circle())
        }
        
    }
}
