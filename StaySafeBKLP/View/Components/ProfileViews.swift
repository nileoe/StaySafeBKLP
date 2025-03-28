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

struct ProfileDetailView<Profile: ProfileDisplayable>: View {
    private let apiService = StaySafeAPIService()
//    let contact: ContactDetail
    let profile: Profile
    @State var currentActivity: Activity? = nil
    @State var isTravelling: Bool? = nil

    var body: some View {
        VStack {
            ProfileDisplay(profile: profile)
                .padding(.vertical)

            if let travelling = isTravelling {
                if travelling {
                    if let activity = currentActivity {
                        ActivityView(
                            activity: activity,
                            viewTitle: "\(profile.userFirstname)'s Current Trip"
                        )
                    } else {
                        Text("Loading current trip...")
                    }
                } else {
                    Text("No current trip to display")
                        .font(.subheadline)
                        .italic()
                }
            } else {
                Text("Checking travel status...")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            self.isTravelling = await profile.isTravelling()
            
            // If the contact is travelling attempt to load the current activity.
            if self.isTravelling == true {
                await loadCurrentActivity()
            }
        }
    }
    
    private func loadCurrentActivity() async {
        do {
            let contactActivities = try await apiService.getActivities(userID: String(profile.userID))
            let currentActivities = contactActivities.filter { $0.isCurrent() }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            // Find the current activity with the most recent (i.e. maximum) departure time.
            let mostRecentActivity = currentActivities.max { (activityA, activityB) in
                guard let dateA = dateFormatter.date(from: activityA.activityLeave),
                      let dateB = dateFormatter.date(from: activityB.activityLeave) else {
                    return false // If one date fails to parse => don't consider it for sorting
                }
                return dateA < dateB
            }
            currentActivity = mostRecentActivity
        } catch {
            print("Error fetching activities: \(error)")
        }
    }
}

struct ProfileAvatarImage: View {
    let profileImageUrl: String?
    let avatarDiameter: CGFloat
    var body: some View {
        if let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty {
            AsyncImage(url: URL(string: profileImageUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: avatarDiameter, height: avatarDiameter)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.fill")
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.gray)
                .clipShape(Circle())
        }
        
    }
}
