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
                        fetchActivities(proxy: proxy)
                    }

                    Button("GET Activity by ID (1)") {
                        fetchActivity(id: "1", proxy: proxy)
                    }

                    Button("GET Activities by User ID (1)") {
                        fetchActivitiesByUser(id: "1", proxy: proxy)
                    }

                    // Locations section
                    sectionHeader("Locations")

                    Button("GET All Locations") {
                        fetchLocations(proxy: proxy)
                    }

                    Button("GET Location by ID (1)") {
                        fetchLocation(id: "1", proxy: proxy)
                    }

                    // Positions section
                    sectionHeader("Positions")

                    Button("GET All Positions") {
                        fetchPositions(proxy: proxy)
                    }

                    Button("GET Position by ID (1)") {
                        fetchPosition(id: "1", proxy: proxy)
                    }

                    Button("GET Positions by Activity ID (2)") {
                        fetchPositionsByActivity(id: "2", proxy: proxy)
                    }

                    // Status section
                    sectionHeader("Status")

                    Button("GET All Statuses") {
                        fetchStatuses(proxy: proxy)
                    }

                    // Users section
                    sectionHeader("Users")

                    Button("GET All Users") {
                        fetchUsers(proxy: proxy)
                    }

                    Button("GET User by ID (1)") {
                        fetchUser(id: "1", proxy: proxy)
                    }

                    Button("GET Contacts by User ID (1)") {
                        fetchContactsByUser(id: "1", proxy: proxy)
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

    /// Generic method to handle API responses
    private func handleApiResponse<T: Encodable>(
        result: Result<T, APIError>,
        title: String
    ) {
        isLoading = false
        switch result {
        case .success(let data):
            responseText = formatForDisplay(data, title: title)
        case .failure(let error):
            responseText = "Error: \(error.description)"
        }
    }

    /// Generic method to make API calls and handle responses
    private func makeApiCall<T: Encodable>(
        title: String,
        proxy: ScrollViewProxy,
        apiCall: @escaping (@escaping (Result<T, APIError>) -> Void) -> Void
    ) {
        isLoading = true
        responseText = "Loading..."
        scrollToResponse(proxy: proxy)

        apiCall { result in
            self.handleApiResponse(result: result, title: title)
        }
    }

    // Format any object for display
    private func formatForDisplay<T: Encodable>(_ object: T, title: String) -> String {
        if let jsonData = try? JSONEncoder().encode(object),
            let prettyPrintedString = String(data: jsonData, encoding: .utf8)
        {
            return "\(title):\n\n\(prettyPrintedString)"
        } else {
            return "Success but couldn't format response."
        }
    }

    // MARK: - API Fetch Methods

    private func fetchActivities(proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET All Activities Response",
            proxy: proxy,
            apiCall: apiService.getAllActivities
        )
    }

    private func fetchActivity(id: String, proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET Activity by ID \(id) Response",
            proxy: proxy,
            apiCall: { completion in
                self.apiService.getActivity(id: id, completion: completion)
            }
        )
    }

    private func fetchActivitiesByUser(id: String, proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET Activities by User ID \(id) Response",
            proxy: proxy,
            apiCall: { completion in
                self.apiService.getActivities(userID: id, completion: completion)
            }
        )
    }

    private func fetchLocations(proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET All Locations Response",
            proxy: proxy,
            apiCall: apiService.getLocations
        )
    }

    private func fetchLocation(id: String, proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET Location by ID \(id) Response",
            proxy: proxy,
            apiCall: { completion in
                self.apiService.getLocation(id: id, completion: completion)
            }
        )
    }

    private func fetchPositions(proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET All Positions Response",
            proxy: proxy,
            apiCall: apiService.getAllPositions
        )
    }

    private func fetchPosition(id: String, proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET Position by ID \(id) Response",
            proxy: proxy,
            apiCall: { completion in
                self.apiService.getPosition(id: id, completion: completion)
            }
        )
    }

    private func fetchPositionsByActivity(id: String, proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET Positions by Activity ID \(id) Response",
            proxy: proxy,
            apiCall: { completion in
                self.apiService.getPositions(activityID: id, completion: completion)
            }
        )
    }

    private func fetchStatuses(proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET All Statuses Response",
            proxy: proxy,
            apiCall: apiService.getStatuses
        )
    }

    private func fetchUsers(proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET All Users Response",
            proxy: proxy,
            apiCall: apiService.getUsers
        )
    }

    private func fetchUser(id: String, proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET User by ID \(id) Response",
            proxy: proxy,
            apiCall: { completion in
                self.apiService.getUser(id: id, completion: completion)
            }
        )
    }

    private func fetchContactsByUser(id: String, proxy: ScrollViewProxy) {
        makeApiCall(
            title: "GET Contacts by User ID \(id) Response",
            proxy: proxy,
            apiCall: { completion in
                self.apiService.getContacts(userID: id, completion: completion)
            }
        )
    }
}
