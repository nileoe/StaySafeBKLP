import Foundation
import SwiftUI

class UserContext: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let apiService = StaySafeAPIService()
    private let userDefaultsKey = "storedUserID"

    init() {
        // Check if there's a stored user ID on init
        checkForStoredUser()
    }

    /// Check if there's a stored user ID and attempt to restore the session
    private func checkForStoredUser() {
        if let storedUserID = UserDefaults.standard.object(forKey: userDefaultsKey) as? Int {
            restoreSession(userID: storedUserID)
        }
    }

    /// Attempt to restore a user session from a stored ID
    func restoreSession(userID: Int) {
        isLoading = true

        Task {
            do {
                let user = try await apiService.getUser(id: String(userID))
                await updateCurrentUser(user)
            } catch {
                await setError("Failed to restore session: \(error.localizedDescription)")
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }

    /// Login with a username
    func login(username: String) {
        isLoading = true
        error = nil

        Task {
            do {
                guard let user = try await apiService.findUserByUsername(username) else {
                    await setError("No user found with that username")
                    return
                }

                // Store the user ID for session persistence
                UserDefaults.standard.set(user.userID, forKey: userDefaultsKey)

                await updateCurrentUser(user)
            } catch {
                await setError("Login failed: \(error.localizedDescription)")
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }

    /// Logout the current user
    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)

        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn = false
        }
    }

    /// Helper method to update the current user on the main thread
    @MainActor
    private func updateCurrentUser(_ user: User) {
        self.currentUser = user
        self.isLoggedIn = true
        self.error = nil
    }

    /// Helper method to set an error on the main thread
    @MainActor
    private func setError(_ message: String) {
        self.error = message
        self.isLoggedIn = false
        self.currentUser = nil
    }
}
