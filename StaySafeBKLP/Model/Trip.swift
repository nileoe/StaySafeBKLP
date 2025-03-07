import SwiftUI

// renaming from the API's 'Activity' to the app's name 'Trip' should probably be taken care of all in here
import Foundation

struct Trip: Codable, Identifiable {
    let id: Int
    var title: String
    let username: String
    var description: String
    let userId: Int
    
    var departureLocationId: Int
    var departureLocationName: String
    var departureTime: Date?
    
    var arrivalLocationId: Int
    var arrivalLocationName: String
    var arrivalTime: Date?
    
    var statusId: Int
    var statusName: String
//    init(id: Int, title: String, username: String, description: String, userId: Int,
//          departureLocationId: Int, departureLocationName: String, departureTime: Date? = nil,
//          arrivalLocationId: Int, arrivalLocationName: String, arrivalTime: Date? = nil,
//          statusId: Int, statusName: String) {
//         self.id = id
//         self.title = title
//         self.username = username
//         self.description = description
//         self.userId = userId
//         self.departureLocationId = departureLocationId
//         self.departureLocationName = departureLocationName
//         self.departureTime = departureTime
//         self.arrivalLocationId = arrivalLocationId
//         self.arrivalLocationName = arrivalLocationName
//         self.arrivalTime = arrivalTime
//         self.statusId = statusId
//         self.statusName = statusName
//     }
    
//    enum CodingKeys: String, CodingKey {
//        case id = "ActivityID"
//        case title = "ActivityName"
//        case username = "ActivityUsername"
//        case description = "ActivityDescription"
//        case userId = "ActivityUserID"
//        
//        case departureLocationId = "ActivityFromID"
//        case departureLocationName = "ActivityFromName"
////        case departureTime = "ActivityLeave"
//        
//        case arrivalLocationId = "ActivityToID"
//        case arrivalLocationName = "ActivityToName"
////        case arrivalTime = "ActivityArrive"
//        
//        case statusId = "ActivityStatusID"
//        case statusName = "ActivityStatusName"
//    }
//    
//    static func getSampleData() -> [Trip] {
//        let trips = [
//            Trip(
//                id: 1,
//                title: "Walk home",
//                username: "aishaahmed",
//                description: "Walk from university to Surbiton train station",
//                userId: 1,
//                departureLocationId: 10,
//                departureLocationName: "Work",
//                arrivalLocationId: 8,
//                arrivalLocationName: "Surbiton Station",
//                statusId: 1,
//                statusName: "Planned"
//            ),
//            Trip(
//                id: 2,
//                title: "Walk home",
//                username: "aishaahmed",
//                description: "Walk from university to Surbiton train station",
//                userId: 1,
//                departureLocationId: 10,
//                departureLocationName: "Work",
//                arrivalLocationId: 8,
//                arrivalLocationName: "Surbiton Station",
//                statusId: 5,
//                statusName: "Completed"
//            ),
//            Trip(
//                id: 3,
//                title: "Visiting Amina",
//                username: "aishaahmed",
//                description: "Dinner at Amina's at 7pm",
//                userId: 1,
//                departureLocationId: 1,
//                departureLocationName: "Berrylands Station",
//                arrivalLocationId: 11,
//                arrivalLocationName: "Amina's",
//                statusId: 5,
//                statusName: "Completed"
//            )
//        ]
//        return trips
//
////        let tripData = """
////        [
////          {
////            "ActivityID": 1,
////            "ActivityName": "Walk home",
////            "ActivityUserID": 1,
////            "ActivityDescription": "Walk from university to Surbiton train station",
////            "ActivityFromID": 10,
////            "ActivityToID": 8,
////            "ActivityStatusID": 1,
////            "ActivityUsername": "aishaahmed",
////            "ActivityFromName": "Work",
////            "ActivityToName": "Surbiton Station",
////            "ActivityStatusName": "Planned"
////          },
////          {
////            "ActivityID": 2,
////            "ActivityName": "Walk home",
////            "ActivityUserID": 1,
////            "ActivityDescription": "Walk from university to Surbiton train station",
////            "ActivityFromID": 10,
////            "ActivityToID": 8,
////            "ActivityStatusID": 5,
////            "ActivityUsername": "aishaahmed",
////            "ActivityFromName": "Work",
////            "ActivityToName": "Surbiton Station",
////            "ActivityStatusName": "Completed"
////          },
////          {
////            "ActivityID": 3,
////            "ActivityName": "Visiting Amina",
////            "ActivityUserID": 1,
////            "ActivityDescription": "Dinner at Amina's at 7pm",
////            "ActivityFromID": 1,
////            "ActivityToID": 11,
////            "ActivityStatusID": 5,
////            "ActivityUsername": "aishaahmed",
////            "ActivityFromName": "Berrylands Station",
////            "ActivityToName": "Amina's",
////            "ActivityStatusName": "Completed"
////          }
////        ]
////        """
//
////        let jsonData = tripData.data(using: .utf8)!
////        let decoder = JSONDecoder()
////        
////        decoder.dateDecodingStrategy = .iso8601
////
////        do {
////            let trips: [Trip] = try! JSONDecoder().decode([Trip].self, from: jsonData)
//////            let trips         = try decoder.decode([Trip].self, from: jsonData)
////            return trips
////        } catch {
////            print("Failed to decode JSON:", error.localizedDescription)
////        }
////        return nil
//    }
}
