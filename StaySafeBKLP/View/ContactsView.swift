import SwiftUI

struct ContactsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Contacts")
                    .foregroundColor(.primary)
            }
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContactsView()
}
