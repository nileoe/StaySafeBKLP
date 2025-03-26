import SwiftUI


struct ActivityView: View {
    @State var activity: Activity
//    @Binding var chosenGenreId: UUID?
    
    var handleConfirm: (() -> Void)?
    var handleCancel: (() -> Void)?
    
    var confirmButtonText: String
    var body: some View {
        Text(activity.activityName)
    }
//        .task {
//            do {
//                activities = try await apiService.getAllActivities()
////            } catch TripError.invalidData {
////                print("Fetching trips: invalid data")
////            } catch TripError.invalidURL {
////                print("Fetching trips: invalid url")
////            } catch TripError.invalidResponse {
////                print("Fetching trips: invalid response")
//            } catch {
//                print("unexpected error when fetching activities")
//            }

//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Trip Details")) {
//                    TextField("Title", text: $activity.activityName)
//                        .autocapitalization(.words)
//                        .disabled(<#T##disabled: Bool##Bool#>)
//                    TextField(
//                        "Description",
//                        text: $activity.activityDescription
//                    )
//                }
//                
//                Section(header: Text("Genre")) {
//                    Picker("Select Genre", selection: $chosenGenreId) {
//                        ForEach(controller.genres, id: \.id) { genre in
//                            Text(genre.name).tag(genre.id)
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                }
//            }
//            .navigationBarTitle(activity.activityName, displayMode: .inline)
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    handleCancel()
//                },
//                trailing: Button(confirmButtonText) {
//                    handleConfirm()
//                }
//                // don't allow books with empty titles or authors
//                    .disabled(book.title.isEmpty || book.author.isEmpty)
//            )
//        }
//    }
}

#Preview {
    ActivityView(
        activity: (Activity(
            activityID: 1,
            activityName: "Morning Hike",
            activityUserID: 101,
            activityUsername: "JohnDoe",
            activityDescription: "A refreshing morning hike through the countryside.",
            activityFromID: 201,
            activityFromName: "Lower Bullington",
            activityLeave: "2025-03-22T08:00:00Z",
            activityToID: 202,
            activityToName: "Highfield Hill",
            activityArrive: "2025-03-22T10:00:00Z",
            activityStatusID: 3,
            activityStatusName: "Planned"
        )),
        handleConfirm: {
            print("Confirm button pressed!")
        },
        handleCancel: {
            print("Cancel button pressed!")
        },
        confirmButtonText: "confi"
    )
}

