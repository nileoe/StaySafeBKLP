import Foundation

/// Defines relationships between users and their contacts.
struct Contact: Codable, Identifiable {
    /// Unique identifier for the contact record
    var contactID: Int
    /// ID of the user who owns the contact
    var contactUserID: Int
    /// ID of the associated contact
    var contactContactID: Int
    /// Relationship label (e.g., "partner", "parent")
    var contactLabel: String
    /// Date when the contact was added
    var contactDateCreated: String

    /// Computed id property for Identifiable conformance
    var id: Int { contactID }

    enum CodingKeys: String, CodingKey {
        case contactID = "ContactID"
        case contactUserID = "ContactUserID"
        case contactContactID = "ContactContactID"
        case contactLabel = "ContactLabel"
        case contactDateCreated = "ContactDateCreated"
    }
}
