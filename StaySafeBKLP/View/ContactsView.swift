import SwiftUI

struct ContactsView: View {
    private let apiService = StaySafeAPIService()
    @EnvironmentObject var userContext: UserContext
    @State private var contacts: [ContactDetail] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                List(contacts, id: \.id) {contact in
                    Text("\(contact.userID)")
                    Text("\(contact.userFirstname)")
                    Text("\(contact.userLastname)")
                    Text("\(contact.userPhone)")
                    Text("\(contact.userUsername)")
                    Text("\(contact.userPassword)")
                    Text("\(contact.userLatitude)")
                    Text("\(contact.userLongitude)")
                    Text("\(contact.userTimestamp)")
                    Text("\(contact.userImageURL)")
                    Text("\(contact.userContactID)")
                    Text("\(contact.userContactLabel)")
                    Text("\(contact.userContactDatecreated)")
                    Text("\(contact.fullName)")
                    Text("###################")
                }
                .task {
                    await loadContacts()
                }
            }
            .navigationTitle("Contacts")
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

#Preview {
    ContactsView()
}

//I want to create a swift component screen that displays a list of the logged in user contact.
//
//struct ContactDetail: Codable, Identifiable {
//    // User information
//    var userID: Int
//    var userFirstname: String
//    var userLastname: String
//    var userPhone: String
//    var userUsername: String
//    var userPassword: String
//    var userLatitude: Double
//    var userLongitude: Double
//    var userTimestamp: Int
//    var userImageURL: String
//    
//    // Contact relationship information
//    var userContactID: Int
//    var userContactLabel: String
//    var userContactDatecreated: String
//    
//    // Conform to Identifiable
//    var id: Int { userContactID }
//    
//    // Full name computed property
//    var fullName: String {
//        "\(userFirstname) \(userLastname)"
//    }
//}
