import SwiftUI

@main
struct StaySafeBKLPApp: App {
    @StateObject private var userContext = UserContext.shared

    var body: some Scene {
        WindowGroup {
            if userContext.isLoggedIn {
                MainTabView()
                    .environmentObject(userContext)
            } else {
                LoginView()
                    .environmentObject(userContext)
            }
        }
    }
}
