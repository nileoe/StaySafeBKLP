import Foundation

 func formattedDate(_ dateString: String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    // Parse the string into a Date object
    guard let date = inputFormatter.date(from: dateString) else {
        return nil
    }

    let outputFormatter = DateFormatter()
    outputFormatter.dateStyle = .short
    outputFormatter.timeStyle = .short

    return outputFormatter.string(from: date)
}
