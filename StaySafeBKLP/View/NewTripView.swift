import Combine
import CoreLocation
import MapKit
import SwiftUI

struct NewTripView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var locationManager = LocationManager()
    @StateObject private var controller: NewTripViewController
    @State private var followUser = false
    @State private var activityCreatedCancellable: AnyCancellable?
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""

    var onActivityCreated: ((Activity) -> Void)?

    init(onActivityCreated: ((Activity) -> Void)? = nil) {
        self.onActivityCreated = onActivityCreated
        let locationManager = LocationManager()
        self._locationManager = StateObject(wrappedValue: locationManager)
        self._controller = StateObject(
            wrappedValue: NewTripViewController(locationManager: locationManager))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(
                    colorScheme == .dark
                        ? Color(UIColor(white: 0.10, alpha: 1.0)) : Color(UIColor.systemGray6)
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Search bar
                        SearchBarView(
                            searchText: Binding(
                                get: { controller.searchQuery },
                                set: { controller.updateSearchQuery($0) }
                            ),
                            isSearchActive: $controller.isSearchActive,
                            onCancel: {
                                controller.clearSearch()
                            },
                            placeholder: "Search for a destination"
                        )

                        // Conditional content: Either search results or map
                        if controller.isSearchActive {
                            // Show search results when search is active
                            SearchResultsView(
                                results: controller.searchResults,
                                onSelectResult: { result in
                                    controller.selectSearchResult(result)
                                }
                            )
                            .transition(.opacity)
                        } else {
                            // Show map when not searching
                            ZStack(alignment: .bottomTrailing) {
                                MapSelectionView(
                                    region: $controller.region,
                                    selectedLocation: $controller.selectedLocation,
                                    locationName: $controller.destinationName
                                )
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(
                                    color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                                    radius: 3, x: 0, y: 2
                                )

                                // Recenter button
                                Button(action: {
                                    controller.centerOnUserLocation()
                                    followUser = true
                                }) {
                                    Image(systemName: "location.fill")
                                        .padding(10)
                                        .background(Color(.systemBackground).opacity(0.9))
                                        .clipShape(Circle())
                                        .shadow(
                                            color: Color.primary.opacity(
                                                colorScheme == .dark ? 0.2 : 0.1),
                                            radius: 2, x: 0, y: 1
                                        )
                                }
                                .padding([.trailing, .bottom], 16)
                            }
                        }

                        VStack(spacing: 16) {
                            // Destination info
                            DestinationSection(destinationName: controller.destinationName)

                            Divider()

                            // Transportation type
                            TransportSection(
                                transportType: $controller.transportType,
                                onChange: controller.calculateEstimatedArrival
                            )

                            Divider()

                            // Time selection
                            DepartureSection(
                                departureDate: $controller.departureDate,
                                onChange: controller.onDepartureDateChanged
                            )

                            // Estimated arrival
                            if controller.isCalculatingRoute
                                || controller.estimatedArrivalTime != nil
                            {
                                Divider()
                                ArrivalTimeSection(
                                    isCalculating: controller.isCalculatingRoute,
                                    arrivalTime: controller.estimatedArrivalTime
                                )
                            }

                            // API status messages
                            if controller.isCreatingActivity {
                                Divider()
                                HStack {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                    Text("Creating trip...")
                                        .foregroundColor(.secondary)
                                }
                            } else if let error = controller.creationError {
                                Divider()
                                VStack(alignment: .leading) {
                                    Text("Error creating trip:")
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)

                                    if let apiError = error as? APIError {
                                        Text(apiError.description)
                                            .foregroundColor(.red)
                                            .font(.footnote)
                                    } else {
                                        Text(error.localizedDescription)
                                            .foregroundColor(.red)
                                            .font(.footnote)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(
                                    color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                                    radius: 3, x: 0, y: 2
                                )
                        )

                        Button(action: createTrip) {
                            let statusEnum =
                                ActivityStatus(rawValue: controller.activityStatusID) ?? .planned
                            Text(statusEnum.buttonText)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(buttonBackground)
                                .cornerRadius(12)
                                .shadow(
                                    color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                                    radius: 3, x: 0, y: 2
                                )
                        }
                        .disabled(
                            controller.selectedLocation == nil || controller.isCreatingActivity
                                || !controller.isDepartureValid)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if controller.selectedLocation == nil {
                    controller.centerOnUserLocation()
                }

                if controller.selectedLocation != nil {
                    controller.calculateEstimatedArrival()
                }

                // Only navigate to map for "Started" trips (status ID = 2)
                activityCreatedCancellable = controller.$createdActivity
                    .compactMap { $0 }
                    .sink { activity in
                        if activity.activityStatusID == 2 {
                            // For "Started" trips, go directly to map
                            onActivityCreated?(activity)
                            dismiss()
                        } else {
                            // For "Planned" trips, show confirmation and reset or dismiss
                            let formattedDate = DateFormattingUtility.formatISOString(
                                activity.activityLeave, style: DateFormattingUtility.mediumDateTime)
                            confirmationMessage = "Trip planned for \(formattedDate)"
                            showingConfirmation = true

                            // Reset form after a short delay or dismiss based on your preference
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }
                    }
            }
            .onDisappear {
                activityCreatedCancellable?.cancel()
            }
            .onChange(of: controller.selectedLocation?.latitude) { _, _ in
                controller.calculateEstimatedArrival()
            }
            .onChange(of: controller.selectedLocation?.longitude) { _, _ in
                controller.calculateEstimatedArrival()
            }
            .alert("Trip Planned", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(confirmationMessage)
            }
        }
    }

    // Helper computed property for button color
    private var buttonBackground: Color {
        if controller.selectedLocation == nil || !controller.isDepartureValid
            || controller.isCreatingActivity
        {
            return Color.gray
        } else {
            let status = ActivityStatus(rawValue: controller.activityStatusID) ?? .planned
            return status.color
        }
    }

    // MARK: - Actions

    private func createTrip() {
        Task {
            await controller.createActivity()
        }
    }
}

// MARK: - Preview
#Preview {
    NewTripView()
}
