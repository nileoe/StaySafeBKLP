import SwiftUI

struct ContactsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Text("Contacts")
                    .foregroundColor(.white)
            }
            .navigationTitle("Contacts")
        }
    }
}
