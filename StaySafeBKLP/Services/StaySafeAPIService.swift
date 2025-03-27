import Foundation

/// Service for interacting with the StaySafe API
class StaySafeAPIService {
    private let apiService = APIService()

    /// A wrapper for the APIService's get method that handles single-item responses
    /// returned as arrays from the API.
    private func getSingleFromArray<T: Codable>(endpoint: String) async throws -> T {
        let items: [T] = try await apiService.get(endpoint: endpoint)
        guard let item = items.first else {
            throw APIError.invalidResponse
        }
        return item
    }

    // MARK: - User API Methods

    /// Fetch all users
    func getUsers() async throws -> [User] {
        return try await apiService.get(endpoint: "users")
    }

    /// Fetch a specific user by ID
    func getUser(id: String) async throws -> User {
        return try await getSingleFromArray(endpoint: "users/\(id)")
    }

    /// Create a new user
    func createUser(user: User) async throws -> User {
        return try await apiService.post(endpoint: "users", body: user)
    }

    /// Update an existing user
    func updateUser(user: User) async throws -> User {
        return try await apiService.put(endpoint: "users/\(user.userID)", body: user)
    }

    /// Delete a user by ID
    func deleteUser(id: String) async throws -> EmptyResponse {
        return try await apiService.delete(endpoint: "users/\(id)")
    }

    /// Find a user by username
    func findUserByUsername(_ username: String) async throws -> User? {
        let users: [User] = try await apiService.get(endpoint: "users?UserUsername=\(username)")
        return users.first
    }

//     MARK: - Contact API Methods

    /// Fetch all contacts for a specific user using ContactDetail model
    func getContacts(userID: String) async throws -> [ContactDetail] {
//        return try await getContactDetails(userID: userID)
        return try await apiService.get(endpoint: "users/contacts/\(userID)")
    }

    /// Fetch a specific contact by ID
    func getContact(id: String) async throws -> Contact {
        return try await getSingleFromArray(endpoint: "contacts/\(id)")
    }

    /// Create a new contact
    func createContact(contact: Contact) async throws -> Contact {
        return try await apiService.post(endpoint: "contacts", body: contact)
    }

    /// Update an existing contact
    func updateContact(contact: Contact) async throws -> Contact {
        return try await apiService.put(endpoint: "contacts/\(contact.contactID)", body: contact)
    }

    /// Delete a contact by ID
    func deleteContact(id: String) async throws -> EmptyResponse {
        return try await apiService.delete(endpoint: "contacts/\(id)")
    }

    // MARK: - Activity API Methods

    /// Fetch all activities for a specific user
    func getActivities(userID: String) async throws -> [Activity] {
        return try await apiService.get(endpoint: "activities/users/\(userID)")
    }

    /// Fetch all activities
    func getAllActivities() async throws -> [Activity] {
        return try await apiService.get(endpoint: "activities")
    }
    
    /// Fetch a user's contact's activities
    func getContactsActivities(userID: String) async throws -> [Activity] {
        let userContacts = try await getContacts(userID: userID)
        var activities: [Activity] = []
        for contact in userContacts {
            let contactActivities: [Activity] = try await getActivities(userID: String(contact.userID))
            for activity in contactActivities {
                activities.append(activity)
            }
        }
        return activities
    }

    /// Fetch a specific activity by ID
    func getActivity(id: String) async throws -> Activity {
        return try await getSingleFromArray(endpoint: "activities/\(id)")
    }

    /// Create a new activity
    func createActivity(activity: Activity) async throws -> Activity {
        return try await apiService.post(endpoint: "activities", body: activity)
    }

    /// Update an existing activity
    func updateActivity(activity: Activity) async throws -> Activity {
        return try await apiService.put(
            endpoint: "activities/\(activity.activityID)", body: activity)
    }

    /// Delete an activity by ID
    func deleteActivity(id: String) async throws -> EmptyResponse {
        return try await apiService.delete(endpoint: "activities/\(id)")
    }

    // MARK: - Location API Methods

    /// Fetch all locations
    func getLocations() async throws -> [Location] {
        return try await apiService.get(endpoint: "locations")
    }

    /// Fetch a specific location by ID
    func getLocation(id: String) async throws -> Location {
        return try await getSingleFromArray(endpoint: "locations/\(id)")
    }

    /// Create a new location
    func createLocation(location: Location) async throws -> Location {
        return try await apiService.post(endpoint: "locations", body: location)
    }

    /// Update an existing location
    func updateLocation(location: Location) async throws -> Location {
        return try await apiService.put(
            endpoint: "locations/\(location.locationID)", body: location)
    }

    /// Delete a location by ID
    func deleteLocation(id: String) async throws -> EmptyResponse {
        return try await apiService.delete(endpoint: "locations/\(id)")
    }

    // MARK: - Status API Methods

    /// Fetch all statuses
    func getStatuses() async throws -> [Status] {
        return try await apiService.get(endpoint: "status")
    }

    /// Fetch a specific status by ID
    func getStatus(id: String) async throws -> Status {
        return try await getSingleFromArray(endpoint: "status/\(id)")
    }

    // MARK: - Position API Methods

    /// Fetch all positions for a specific activity
    func getPositions(activityID: String) async throws -> [Position] {
        return try await apiService.get(endpoint: "positions/activities/\(activityID)")
    }

    /// Fetch all positions
    func getAllPositions() async throws -> [Position] {
        return try await apiService.get(endpoint: "positions")
    }

    /// Fetch a specific position by ID
    func getPosition(id: String) async throws -> Position {
        return try await getSingleFromArray(endpoint: "positions/\(id)")
    }

    /// Create a new position
    func createPosition(position: Position) async throws -> Position {
        return try await apiService.post(endpoint: "positions", body: position)
    }

    /// Delete a position by ID
    func deletePosition(id: String) async throws -> EmptyResponse {
        return try await apiService.delete(endpoint: "positions/\(id)")
    }
}
