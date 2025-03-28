import CoreLocation
import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var controller: MapViewController
    @State private var showingNewTripView = false
    @State private var showingTripDetails = false
    @State private var selectedActivity: Activity? = nil
    @State private var locationData: [Int: Location] = [:]

    init() {
        self._controller = StateObject(
            wrappedValue: MapViewController(locationManager: LocationManager.shared))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Map layer
                mapLayer
                    .ignoresSafeArea()

                // UI overlays
                VStack(spacing: 0) {
                    activityCardArea
                    Spacer()
                    controlButtons
                }
            }
            .navigationTitle("Map")
            .onAppear {
                controller.setInitialLocation(locationManager.userLocation)
                controller.checkForActiveTrip()
            }
            .sheet(isPresented: $showingNewTripView) {
                NewTripView(onActivityCreated: { activity in
                    if activity.hasStarted() {
                        controller.handleActivityCreated(activity)
                    }
                })
            }
            .sheet(isPresented: $showingTripDetails, onDismiss: controller.checkForActiveTrip) {
                if let activity = selectedActivity {
                    TripDetailsView(activity: activity, onEndTrip: controller.clearCurrentTrip)
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name("ActivityStatusChanged"))
            ) { notification in
                if let activity = notification.object as? Activity {
                    controller.handleActivityStateChange(activity)
                }
            }
        }
    }

    // MARK: - View Components

    private var mapLayer: some View {
        Group {
            if let route = controller.currentRoute,
                let destination = controller.destinationCoordinate
            {
                UIKitMapViewWithRoute(
                    region: $controller.region,
                    followUser: $controller.followUser,
                    route: route,
                    destination: destination
                )
            } else {
                UIKitMapView(
                    region: $controller.region,
                    followUser: $controller.followUser
                )
            }
        }
    }

    private var activityCardArea: some View {
        VStack {
            if let activity = controller.currentActivity {
                UniversalActivityCard(
                    activity: activity,
                    location: locationData[activity.activityToID],
                    displayMode: .banner,
                    contactName: nil,
                    contactImageURL: nil,
                    onCardTap: { showDetailsForActivity(activity) },
                    onViewTrip: nil,
                    onEndTrip: nil
                )
                .task {
                    if locationData[activity.activityToID] == nil {
                        await fetchLocationForActivity(activity)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var controlButtons: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: controller.centerOnUser) {
                    Image(systemName: "location.fill")
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(.trailing, 20)
            }

            if controller.currentActivity == nil {
                WideRectangleButton(
                    text: "Create Trip",
                    backgroundColor: .blue,
                    foregroundColor: .white,
                    action: { showingNewTripView = true }
                )
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - Helper Methods

    private func showDetailsForActivity(_ activity: Activity) {
        selectedActivity = activity
        showingTripDetails = true
    }

    private func handleNewActivity(_ activity: Activity) {
        if activity.isCurrent() {
            controller.handleActivityCreated(activity)
        }
    }

    private func fetchLocationForActivity(_ activity: Activity) async {
        do {
            let location = try await StaySafeAPIService().getLocation(
                id: String(activity.activityToID))
            await MainActor.run { locationData[activity.activityToID] = location }
        } catch {
        }
    }
}

// MARK: - Preview
#Preview {
    MapView()
}
