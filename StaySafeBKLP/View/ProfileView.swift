import MapKit
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userContext: UserContext

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20) {
                // Profile Image
                profileImage

                // User Info
                if let user = userContext.currentUser {
                    userInfoSection(user: user)
                        .padding(.top, 40)
                } else {
                    Text("User information not available")
                        .foregroundColor(.secondary)
                }

                // Logout Button
                Button(action: {
                    userContext.logout()
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                
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

    // MARK: - Components

    private var profileImage: some View {
        Group {
            if let imageURL = userContext.currentUser?.userImageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                .shadow(radius: 5)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
            }
        }
    }

    private func userInfoSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(user.fullName)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)

            infoRow(title: "Username", value: user.userUsername)
            infoRow(title: "Phone", value: user.userPhone)
            infoRow(title: "User ID", value: String(user.userID))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }

    private func infoRow(title: String, value: String) -> some View {
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
