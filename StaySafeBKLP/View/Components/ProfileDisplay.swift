import SwiftUI

struct ProfileDisplay<Profile: ProfileDisplayable>: View {
    let profile: Profile
    var body: some View {
        VStack {
            ProfileImage(imageURL: profile.userImageURL)
            UserInfoSection(
                fullName: profile.fullName,
                username: profile.userUsername,
                phone: profile.userPhone
            )
                .padding(.top, 40)
        }
    }
}

struct ProfileImage: View {
    let imageURL: String?
    
    var body: some View {
        Group {
            if let imageURL = imageURL {
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
}
