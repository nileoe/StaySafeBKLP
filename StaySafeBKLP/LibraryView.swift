import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Text("Library")
                    .foregroundColor(.white)
            }
            .navigationTitle("Library")
        }
    }
}
