import SwiftUI

struct ProfileView: View {
    var body: some View {
            NavigationStack {
                
                List {
                    // User profile information section could go here
                    Section(header: Text("Profile")) {
                        Text("Profile")
                            .foregroundColor(.primary)
                    }
                    // API Testing section
                    Section(header: Text("Developer")) {
                        NavigationLink(destination: APITestingView()) {
                            HStack {
                                Image(systemName: "network")
                                Text("API Testing")
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
            }
        }
}

#Preview {
    ProfileView()
}
