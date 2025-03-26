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
    
    var body: some View {
        HStack(spacing: 12) {
            statusIndicator
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
                    if (contact.isTravelling()) {
                        Text("Currently travelling")
                            .font(.footnote)
                            .foregroundColor(.white)      // Set the text color to white
                            .padding(5)                   // Add some internal padding
                            .background(Color.green)      // Set the background color to green
                            .cornerRadius(5)              // Optional: Add rounded corners for a nicer look
                    }
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
                DateFormattingUtility.contactColor(for: String(contact.userContactID))
            )
            .frame(width: 12, height: 12)
    }
}

struct ContactDetailView: View {
    var contact: ContactDetail
    var body: some View {
        ProfileDisplay(profile: contact)
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
