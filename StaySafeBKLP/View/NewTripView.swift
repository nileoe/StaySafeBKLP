import CoreLocation
import MapKit
import SwiftUI

struct NewTripView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var controller: NewTripViewController
    @State private var followUser = false

    var onTripCreated:
        ((CLLocationCoordinate2D, String, MKDirectionsTransportType, Date, Date?) -> Void)?

    init(
        onTripCreated: (
            (CLLocationCoordinate2D, String, MKDirectionsTransportType, Date, Date?) -> Void
        )? = nil
    ) {
        self.onTripCreated = onTripCreated
        let locationManager = LocationManager()
        self._locationManager = StateObject(wrappedValue: locationManager)
        self._controller = StateObject(
            wrappedValue: NewTripViewController(locationManager: locationManager))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack(alignment: .bottomTrailing) {
                        MapSelectionView(
                            region: $controller.region,
                            selectedLocation: $controller.selectedLocation,
                            locationName: $controller.destinationName
                        )
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 3)

                        // Recenter button
                        Button(action: {
                            controller.centerOnUserLocation()
                            followUser = true
                        }) {
                            Image(systemName: "location.fill")
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding([.trailing, .bottom], 16)
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
                            onChange: controller.calculateEstimatedArrival
                        )

                        // Estimated arrival
                        if controller.isCalculatingRoute || controller.estimatedArrivalTime != nil {
                            Divider()
                            ArrivalTimeSection(
                                isCalculating: controller.isCalculatingRoute,
                                arrivalTime: controller.estimatedArrivalTime
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                    )

                    Button(action: createTrip) {
                        Text("Create Trip")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                controller.selectedLocation != nil ? Color.blue : Color.gray
                            )
                            .cornerRadius(12)
                    }
                    .disabled(controller.selectedLocation == nil)
                }
                .padding()
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
            .onReceive(locationManager.$userLocation) { location in
                if controller.selectedLocation == nil, let userLocation = location {
                    controller.region = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
            .onAppear {
                if controller.selectedLocation != nil {
                    controller.calculateEstimatedArrival()
                }
            }
            .onChange(of: controller.selectedLocation?.latitude) { _, _ in
                controller.calculateEstimatedArrival()
            }
            .onChange(of: controller.selectedLocation?.longitude) { _, _ in
                controller.calculateEstimatedArrival()
            }
        }
    }

    // MARK: - Actions

    private func createTrip() {
        if let selectedLocation = controller.selectedLocation {
            onTripCreated?(
                selectedLocation,
                controller.destinationName,
                controller.transportType.mapKitType,
                controller.departureDate,
                controller.estimatedArrivalTime
            )
            dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    NewTripView()
}
