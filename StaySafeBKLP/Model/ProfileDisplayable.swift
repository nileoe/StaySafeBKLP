protocol ProfileDisplayable {
    var userID: Int { get }
    var fullName: String { get }
    var userImageURL: String? { get }
    var userUsername: String { get }
    var userPhone: String { get }
    var userFirstname: String { get }
    func isTravelling() async -> Bool
}
