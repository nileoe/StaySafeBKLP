import SwiftUI

struct APITestingView: View {
    private let apiService = StaySafeAPIService()
    @State private var responseText = "Response will appear here..."
    @State private var isLoading = false

    // For scrolling to bottom when response arrives
    @State private var scrollToBottom = false
    @Namespace private var bottomID

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("StaySafe API Testing")
                        .font(.largeTitle)
                        .padding(.bottom)

                    // Activities section
                    sectionHeader("Activities")

                    Button("GET All Activities") {
                        Task { await fetchActivities(proxy: proxy) }
                    }

                    Button("GET Activity by ID (1)") {
                        Task { await fetchActivity(id: "1", proxy: proxy) }
                    }

                    Button("GET Activities by User ID (1)") {
                        Task { await fetchActivitiesByUser(id: "1", proxy: proxy) }
                    }
          
                    Button("GET Contact Activities for User ID (1)") {
                        Task { await fetchContactActivitiesByUser(id: "1", proxy: proxy) }
                    }

                    // Locations section
                    sectionHeader("Locations")

                    Button("GET All Locations") {
                        Task { await fetchLocations(proxy: proxy) }
                    }

                    Button("GET Location by ID (1)") {
                        Task { await fetchLocation(id: "1", proxy: proxy) }
                    }

                    // Positions section
                    sectionHeader("Positions")

                    Button("GET All Positions") {
                        Task { await fetchPositions(proxy: proxy) }
                    }

                    Button("GET Position by ID (1)") {
                        Task { await fetchPosition(id: "1", proxy: proxy) }
                    }

                    Button("GET Positions by Activity ID (2)") {
                        Task { await fetchPositionsByActivity(id: "2", proxy: proxy) }
                    }

                    // Status section
                    sectionHeader("Status")

                    Button("GET All Statuses") {
                        Task { await fetchStatuses(proxy: proxy) }
                    }

                    // Users section
                    sectionHeader("Users")

                    Button("GET All Users") {
                        Task { await fetchUsers(proxy: proxy) }
                    }

                    Button("GET User by ID (1)") {
                        Task { await fetchUser(id: "1", proxy: proxy) }
                    }

                    Button("GET Contacts by User ID (1)") {
                        Task { await fetchContactsByUser(id: "1", proxy: proxy) }
                    }

                    Divider()

                    VStack(alignment: .leading) {
                        Text("Response:")
                            .font(.headline)
                            .id(bottomID)  // Mark this for scrolling

                        if isLoading {
                            ProgressView("Loading...")
                                .padding()
                        } else {
                            Text(responseText)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .onChange(of: scrollToBottom) {
                    withAnimation {
                        proxy.scrollTo(bottomID, anchor: .top)
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.top, 10)
    }

    private func scrollToResponse(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            scrollToBottom.toggle()
        }
    }

    // MARK: - Generic Response Handlers

    /// Format any object for display
    private func formatForDisplay<T: Encodable>(_ object: T, title: String) -> String {
        if let jsonData = try? JSONEncoder().encode(object),
            let prettyPrintedString = String(data: jsonData, encoding: .utf8)
        {
            return "\(title):\n\n\(prettyPrintedString)"
        } else {
            return "Success but couldn't format response."
        }
    }

    // Generic method to execute API calls with async/await
    private func executeApiCall<T: Encodable>(
        title: String,
        proxy: ScrollViewProxy,
        action: () async throws -> T
    ) async {
        isLoading = true
        responseText = "Loading..."
        scrollToResponse(proxy: proxy)

        do {
            let result = try await action()
            isLoading = false
            responseText = formatForDisplay(result, title: title)
        } catch let error as APIError {
            isLoading = false
            responseText = "Error: \(error.description)"
        } catch {
            isLoading = false
            responseText = "Unexpected error: \(error.localizedDescription)"
        }
    }

    // MARK: - API Fetch Methods

    private func fetchActivities(proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET All Activities Response",
            proxy: proxy,
            action: apiService.getAllActivities
        )
    }

    private func fetchActivity(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET Activity by ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getActivity(id: id) }
        )
    }

    private func fetchActivitiesByUser(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET Activities by User ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getActivities(userID: id) }
        )
    }
    
    private func fetchContactActivitiesByUser(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET Contact Activities by User ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getContactsActivities(userID: id) }
        )
    }

    private func fetchLocations(proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET All Locations Response",
            proxy: proxy,
            action: apiService.getLocations
        )
    }

    private func fetchLocation(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET Location by ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getLocation(id: id) }
        )
    }

    private func fetchPositions(proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET All Positions Response",
            proxy: proxy,
            action: apiService.getAllPositions
        )
    }

    private func fetchPosition(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET Position by ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getPosition(id: id) }
        )
    }

    private func fetchPositionsByActivity(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET Positions by Activity ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getPositions(activityID: id) }
        )
    }

    private func fetchStatuses(proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET All Statuses Response",
            proxy: proxy,
            action: apiService.getStatuses
        )
    }

    private func fetchUsers(proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET All Users Response",
            proxy: proxy,
            action: apiService.getUsers
        )
    }

    private func fetchUser(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET User by ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getUser(id: id) }
        )
    }

    private func fetchContactsByUser(id: String, proxy: ScrollViewProxy) async {
        await executeApiCall(
            title: "GET Contacts by User ID \(id) Response",
            proxy: proxy,
            action: { try await apiService.getContacts(userID: id) }
        )
    }
}

#Preview {
    APITestingView()
}
