import SwiftUI

struct TripsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Trips")
                    .foregroundColor(.primary)
            }
            .navigationTitle("Trips")
        }
    }
}

#Preview {
    TripsView()
}
