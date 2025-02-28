import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Map")
                    .foregroundColor(.primary)
            }
            .navigationTitle("Map")
        }
    }
}

#Preview {
    MapView()
}
