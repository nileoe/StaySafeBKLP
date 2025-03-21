import Foundation

/// Service for interacting with the StaySafe API
class StaySafeAPIService {
    private let apiService = APIService()

    /// A wrapper for the APIService's get method that handles single-item responses
    /// returned as arrays from the API.
    private func getSingleFromArray<T: Codable>(
        endpoint: String,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        apiService.get(endpoint: endpoint) { (result: Result<[T], APIError>) in
            switch result {
            case .success(let items):
                if let item = items.first {
                    completion(.success(item))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - User API Methods

    /// Fetch all users
    func getUsers(completion: @escaping (Result<[User], APIError>) -> Void) {
        apiService.get(endpoint: "users", completion: completion)
    }

    /// Fetch a specific user by ID
    func getUser(id: String, completion: @escaping (Result<User, APIError>) -> Void) {
        getSingleFromArray(endpoint: "users/\(id)", completion: completion)
    }

    /// Create a new user
    func createUser(user: User, completion: @escaping (Result<User, APIError>) -> Void) {
        apiService.post(endpoint: "users", body: user, completion: completion)
    }

    /// Update an existing user
    func updateUser(user: User, completion: @escaping (Result<User, APIError>) -> Void) {
        apiService.put(endpoint: "users/\(user.userID)", body: user, completion: completion)
    }

    /// Delete a user by ID
    func deleteUser(id: String, completion: @escaping (Result<EmptyResponse, APIError>) -> Void) {
        apiService.delete(endpoint: "users/\(id)", completion: completion)
    }

    // MARK: - Contact API Methods

    /// Fetch all contacts with user details for a specific user
    func getContactDetails(
        userID: String, completion: @escaping (Result<[ContactDetail], APIError>) -> Void
    ) {
        apiService.get(endpoint: "users/contacts/\(userID)", completion: completion)
    }

    /// Fetch all contacts for a specific user using ContactDetail model
    func getContacts(
        userID: String, completion: @escaping (Result<[ContactDetail], APIError>) -> Void
    ) {
        getContactDetails(userID: userID, completion: completion)
    }

    /// Fetch a specific contact by ID
    func getContact(id: String, completion: @escaping (Result<Contact, APIError>) -> Void) {
        getSingleFromArray(endpoint: "contacts/\(id)", completion: completion)
    }

    /// Create a new contact
    func createContact(contact: Contact, completion: @escaping (Result<Contact, APIError>) -> Void)
    {
        apiService.post(endpoint: "contacts", body: contact, completion: completion)
    }

    /// Update an existing contact
    func updateContact(contact: Contact, completion: @escaping (Result<Contact, APIError>) -> Void)
    {
        apiService.put(
            endpoint: "contacts/\(contact.contactID)", body: contact, completion: completion)
    }

    /// Delete a contact by ID
    func deleteContact(id: String, completion: @escaping (Result<EmptyResponse, APIError>) -> Void)
    {
        apiService.delete(endpoint: "contacts/\(id)", completion: completion)
    }

    // MARK: - Activity API Methods

    /// Fetch all activities for a specific user
    func getActivities(userID: String, completion: @escaping (Result<[Activity], APIError>) -> Void)
    {
        apiService.get(endpoint: "activities/users/\(userID)", completion: completion)
    }

    /// Fetch all activities
    func getAllActivities(completion: @escaping (Result<[Activity], APIError>) -> Void) {
        apiService.get(endpoint: "activities", completion: completion)
    }

    /// Fetch a specific activity by ID
    func getActivity(id: String, completion: @escaping (Result<Activity, APIError>) -> Void) {
        getSingleFromArray(endpoint: "activities/\(id)", completion: completion)
    }

    /// Create a new activity
    func createActivity(
        activity: Activity, completion: @escaping (Result<Activity, APIError>) -> Void
    ) {
        apiService.post(endpoint: "activities", body: activity, completion: completion)
    }

    /// Update an existing activity
    func updateActivity(
        activity: Activity, completion: @escaping (Result<Activity, APIError>) -> Void
    ) {
        apiService.put(
            endpoint: "activities/\(activity.activityID)", body: activity, completion: completion)
    }

    /// Delete an activity by ID
    func deleteActivity(id: String, completion: @escaping (Result<EmptyResponse, APIError>) -> Void)
    {
        apiService.delete(endpoint: "activities/\(id)", completion: completion)
    }

    // MARK: - Location API Methods

    /// Fetch all locations
    func getLocations(completion: @escaping (Result<[Location], APIError>) -> Void) {
        apiService.get(endpoint: "locations", completion: completion)
    }

    /// Fetch a specific location by ID
    func getLocation(id: String, completion: @escaping (Result<Location, APIError>) -> Void) {
        getSingleFromArray(endpoint: "locations/\(id)", completion: completion)
    }

    /// Create a new location
    func createLocation(
        location: Location, completion: @escaping (Result<Location, APIError>) -> Void
    ) {
        apiService.post(endpoint: "locations", body: location, completion: completion)
    }

    /// Update an existing location
    func updateLocation(
        location: Location, completion: @escaping (Result<Location, APIError>) -> Void
    ) {
        apiService.put(
            endpoint: "locations/\(location.locationID)", body: location, completion: completion)
    }

    /// Delete a location by ID
    func deleteLocation(id: String, completion: @escaping (Result<EmptyResponse, APIError>) -> Void)
    {
        apiService.delete(endpoint: "locations/\(id)", completion: completion)
    }

    // MARK: - Status API Methods

    /// Fetch all statuses
    func getStatuses(completion: @escaping (Result<[Status], APIError>) -> Void) {
        apiService.get(endpoint: "status", completion: completion)
    }

    /// Fetch a specific status by ID
    func getStatus(id: String, completion: @escaping (Result<Status, APIError>) -> Void) {
        getSingleFromArray(endpoint: "status/\(id)", completion: completion)
    }

    // MARK: - Position API Methods

    /// Fetch all positions for a specific activity
    func getPositions(
        activityID: String, completion: @escaping (Result<[Position], APIError>) -> Void
    ) {
        apiService.get(endpoint: "positions/activities/\(activityID)", completion: completion)
    }

    /// Fetch all positions
    func getAllPositions(completion: @escaping (Result<[Position], APIError>) -> Void) {
        apiService.get(endpoint: "positions", completion: completion)
    }

    /// Fetch a specific position by ID
    func getPosition(id: String, completion: @escaping (Result<Position, APIError>) -> Void) {
        getSingleFromArray(endpoint: "positions/\(id)", completion: completion)
    }

    /// Create a new position
    func createPosition(
        position: Position, completion: @escaping (Result<Position, APIError>) -> Void
    ) {
        apiService.post(endpoint: "positions", body: position, completion: completion)
    }

    /// Delete a position by ID
    func deletePosition(id: String, completion: @escaping (Result<EmptyResponse, APIError>) -> Void)
    {
        apiService.delete(endpoint: "positions/\(id)", completion: completion)
    }
}
