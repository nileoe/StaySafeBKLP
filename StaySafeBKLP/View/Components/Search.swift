import MapKit
import SwiftUI

struct SearchBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchText: String
    @Binding var isSearchActive: Bool
    var onCancel: () -> Void
    var placeholder: String
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField(placeholder, text: $searchText)
                    .disableAutocorrection(true)
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        if !isSearchActive {
                            isSearchActive = true
                        }
                    }
                    .onChange(of: isSearchActive) { _, newValue in
                        if !newValue {
                            isTextFieldFocused = false
                        }
                    }
                    .submitLabel(.search)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(
                Color(
                    colorScheme == .dark
                        ? UIColor(white: 0.2, alpha: 1.0)
                        : .white)
            )
            .cornerRadius(10)
            .shadow(
                color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                radius: 2, x: 0, y: 1
            )

            if isSearchActive {
                Button("Cancel") {
                    onCancel()
                    isTextFieldFocused = false
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
}

struct SearchResultsView: View {
    @Environment(\.colorScheme) var colorScheme
    let results: [MKLocalSearchCompletion]
    let onSelectResult: (MKLocalSearchCompletion) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if results.isEmpty {
                VStack {
                    Text("No results found")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(
                    color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                    radius: 5, x: 0, y: 3
                )
            } else {
                List {
                    ForEach(results, id: \.self) { result in
                        Button(action: {
                            onSelectResult(result)
                        }) {
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .font(.headline)
                                Text(result.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(
                    color: Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                    radius: 5, x: 0, y: 3
                )
            }
        }
        .frame(height: 250)  // Fixed height to match map view
    }
}
