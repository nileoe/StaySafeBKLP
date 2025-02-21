import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Text("Map")
                    .foregroundColor(.white)
            }
            .navigationTitle("Map")
        }
    }
}
