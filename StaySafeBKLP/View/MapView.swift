import CoreLocation
import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var controller: MapViewController
    @State private var showingNewTripView = false
    @State private var showingTripDetails = false

    init() {
        let locationManager = LocationManager()
        self._locationManager = StateObject(wrappedValue: locationManager)
        self._controller = StateObject(
            wrappedValue: MapViewController(locationManager: locationManager))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Map layer
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
                .ignoresSafeArea()

                // UI overlays
                VStack {
                    // Trip banner (when active)
                    if let activity = controller.currentActivity {
                        TripBanner(
                            activity: activity,
                            onTap: { showingTripDetails = true }
                        )
                    }

                    Spacer()

                    // Recenter button
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
                        WideRectangleButton(
                            text: "Create Trip",
                            backgroundColor: .blue,
                            foregroundColor: .white,
                            action: { showingNewTripView = true }
                        )
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Map")
            .onAppear {
                controller.setInitialLocation(locationManager.userLocation)
                controller.checkForActiveTrip()  // Add check for active trips when view appears
            }
            .sheet(isPresented: $showingNewTripView) {
                NewTripView(onActivityCreated: { activity in
                    if activity.activityStatusID == 2 {
                        controller.handleActivityCreated(activity)
                    }
                })
            }
            .sheet(isPresented: $showingTripDetails) {
                if let activity = controller.currentActivity {
                    TripDetailsView(
                        activity: activity,
                        onEndTrip: {
                            controller.clearCurrentTrip()
                        })
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MapView()
}
