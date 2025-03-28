import MapKit
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userContext: UserContext
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20) {
                if let user = userContext.currentUser {
                    ProfileDisplay(profile: user)
                } else {
                    Text("User information not available")
                        .foregroundColor(.secondary)
                }
                
                // Logout Button
                GradientActionButton(
                    title: "Log Out",
                    systemImage: nil,
                    baseColor: .red,
                    action: {
                        userContext.logout()
                    }
                )
                .padding(.horizontal)

                Spacer()
                
                // API Testing section
                NavigationLink(destination: APITestingView()) {
                    HStack {
                        Image(systemName: "network")
                        Text("API Testing")
                    }
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Components




struct UserInfoSection: View {
    let fullName: String
    let username: String
    let phone: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(fullName)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            infoRow(title: "Username", value: username)
            infoRow(title: "Phone", value: phone)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

struct infoRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title + ":")
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(
            {
                let context = UserContext()
                context.currentUser = User(
                    userID: 1,
                    userFirstname: "John",
                    userLastname: "Doe",
                    userPhone: "+1234567890",
                    userUsername: "johndoe",
                    userPassword: "password",
                    userLatitude: 47.6062,
                    userLongitude: -122.3321,
                    userTimestamp: Int(Date().timeIntervalSince1970),
                    userImageURL: nil
                )
                context.isLoggedIn = true
                return context
            }())
}
