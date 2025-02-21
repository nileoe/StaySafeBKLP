import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Text("Profile")
                    .foregroundColor(.white)
            }
            .navigationTitle("Profile")
        }
    }
}
