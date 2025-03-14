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
                    if let trip = controller.currentTrip, let route = trip.route {
                        UIKitMapViewWithRoute(
                            region: $controller.region,
                            followUser: $controller.followUser,
                            route: route,
                            destination: trip.destination
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
//                    if let trip = controller.currentTrip {
//                        tripBanner(trip)
//                    }
//                    
                    // Trip banner (when active)
                    if let trip = controller.currentTrip {
                        TripBanner(
                            trip: trip,
                            timeFormatter: controller.timeFormatter,
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

                        Button(action: { showingNewTripView = true }) {
                            Text("Create Trip")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Map")
            .onAppear {
                controller.setInitialLocation(locationManager.userLocation)
            }
            .sheet(isPresented: $showingNewTripView) {
                NewTripView(onTripCreated: controller.createTrip)
            }
            .sheet(isPresented: $showingTripDetails) {
                if let trip = controller.currentTrip {
                    TripDetailsView(trip: trip) {
                        controller.currentTrip = nil
                    }
                }
            }
        }
    }

    // MARK: - UI Components

    private func tripBanner(_ trip: TripDetails) -> some View {
        Button(action: { showingTripDetails = true }) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Trip to \(trip.destinationName)")
                        .font(.headline)
                    
                    if let arrival = trip.estimatedArrivalTime {
                        Text("Arrival: \(arrival, formatter: controller.timeFormatter)")
                            .font(.subheadline)
                    }
                }
                .padding(.leading)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    MapView()
}
