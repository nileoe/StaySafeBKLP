import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Home")
                    .foregroundColor(.primary)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
