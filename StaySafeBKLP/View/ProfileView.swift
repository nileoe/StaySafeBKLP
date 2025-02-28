import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Profile")
                    .foregroundColor(.primary)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
