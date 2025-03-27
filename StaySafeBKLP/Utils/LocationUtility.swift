import CoreLocation
import Foundation

class LocationUtility {

    // MARK: - Geocoding Core Methods

    /// Core geocoding method - converts coordinates to location information
    /// - Parameters:
    ///   - latitude: The latitude coordinate
    ///   - longitude: The longitude coordinate
    /// - Returns: A tuple with placemark and any error that occurred
    static func reverseGeocode(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async -> (
        placemark: CLPlacemark?, error: Error?
    ) {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        return await withCheckedContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                continuation.resume(returning: (placemarks?.first, error))
            }
        }
    }

    /// Extract a dictionary of location details from a placemark
    /// - Parameter placemark: The placemark to extract details from
    /// - Returns: Dictionary containing location components
    static func locationDetails(from placemark: CLPlacemark) -> [String: String] {
        var result: [String: String] = [:]

        if let name = placemark.name {
            result["name"] = name
        }

        if let thoroughfare = placemark.thoroughfare {
            result["street"] = thoroughfare
        }

        if let locality = placemark.locality {
            result["city"] = locality
        }

        if let administrativeArea = placemark.administrativeArea {
            result["state"] = administrativeArea
        }

        if let country = placemark.country {
            result["country"] = country
        }

        if let postalCode = placemark.postalCode {
            result["postalCode"] = postalCode
        }

        return result
    }

    /// Format an address string from a placemark
    /// - Parameter placemark: The placemark to format
    /// - Returns: Formatted address string or nil if not available
    static func formattedAddress(from placemark: CLPlacemark) -> String? {
        var addressComponents: [String] = []

        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }

        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }

        if let locality = placemark.locality {
            addressComponents.append(locality)
        }

        if let administrativeArea = placemark.administrativeArea, !administrativeArea.isEmpty {
            addressComponents.append(administrativeArea)
        }

        if let country = placemark.country {
            addressComponents.append(country)
        }

        let address = addressComponents.joined(separator: ", ")
        return address.isEmpty ? nil : address
    }

    // MARK: - Public Geocoding Methods

    static func getMeaningfulLocationName(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
        async -> String
    {
        let (placemark, _) = await reverseGeocode(latitude: latitude, longitude: longitude)
        guard let placemark = placemark else { return "Current Location" }

        let details = locationDetails(from: placemark)

        // Try to construct a meaningful name from the available info
        if let city = details["city"] {
            if let street = details["street"] {
                return "Current Location (\(street), \(city))"
            }
            return "Current Location (\(city))"
        }

        if let name = details["name"] {
            return "Current Location (\(name))"
        }

        // Default fallback
        return "Current Location"
    }

    /// Extract a simplified location name from a full address
    /// - Parameter address: Full address string (e.g., "101 Riverview Road, Riverview Road, Epsom, England")
    /// - Returns: A simplified location name (e.g., "Riverview Road")
    static func extractSimplifiedLocationName(from address: String) -> String {
        let comps = address.components(separatedBy: ", ").filter { !$0.isEmpty }
        guard !comps.isEmpty else { return "Location" }
        return comps.count > 1 && comps[0].first?.isNumber == true ? comps[1] : comps[0]
    }

    static func fetchPostcode(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async
        -> String?
    {
        let (placemark, _) = await reverseGeocode(latitude: latitude, longitude: longitude)
        return placemark?.postalCode
    }

    static func getAddressFromCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
        async -> String?
    {
        let (placemark, _) = await reverseGeocode(latitude: latitude, longitude: longitude)
        guard let placemark = placemark else { return nil }
        return formattedAddress(from: placemark)
    }

    /// Extract a cleaned description from a full address by removing redundant parts
    /// - Parameter address: Full address string (e.g., "9 Colne Court, Colne Court, Chessington, England")
    /// - Returns: A cleaned description (e.g., "9 Colne Court, Chessington, England")
    static func extractLocationDescription(from address: String) -> String {
        let components = address.components(separatedBy: ", ").filter { !$0.isEmpty }
        guard components.count > 2 else { return address }

        var result = [components[0]]  // Keep the first part (usually house number + street)

        // Skip any component that's the same as the second part of the first component
        // For example, if first part is "9 Colne Court", skip any "Colne Court" components
        let firstPartElements = components[0].components(separatedBy: " ")
        let streetName =
            firstPartElements.count > 1 ? firstPartElements.dropFirst().joined(separator: " ") : ""

        // Add remaining components except those matching the street name
        for i in 1..<components.count {
            if components[i] != streetName {
                result.append(components[i])
            }
        }

        return result.joined(separator: ", ")
    }

    // MARK: - Location Search

    /// Find a location in the database that matches the given coordinates within a radius
    /// - Parameters:
    ///   - latitude: The target latitude
    ///   - longitude: The target longitude
    ///   - tolerance: The maximum difference to consider a match (default: 0.001 degrees, ~100m)
    /// - Returns: The matching location if found, nil otherwise
    static func findNearbyLocation(latitude: Double, longitude: Double, tolerance: Double = 0.001)
        async throws -> Location?
    {
        let locations: [Location] = try await StaySafeAPIService().getLocations()

        // Find the first location that's within the tolerance range for both lat and long
        return locations.first { location in
            let latDiff = abs(location.locationLatitude - latitude)
            let longDiff = abs(location.locationLongitude - longitude)
            return latDiff <= tolerance && longDiff <= tolerance
        }
    }

    // MARK: - Location Creation

    /// Create or get a location record
    static func createOrGetLocation(
        name: String,
        coordinates: CLLocationCoordinate2D,
        description: String? = nil,
        address: String? = nil,
        isDestination: Bool = false
    ) async throws -> Location {
        let apiService = StaySafeAPIService()

        // Get a better address if the provided one is generic or empty
        var locationAddress = address ?? ""
        if locationAddress == "Current user location" || locationAddress.isEmpty {
            if let betterAddress = await getAddressFromCoordinates(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            ) {
                locationAddress = betterAddress
            }
        }

        // Try to find by coordinates
        if let existingLocation = try await findNearbyLocation(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            tolerance: 0.0005  // ~50 meters
        ) {
            print(
                "Found existing location by coordinates: \(existingLocation.locationName) with ID: \(existingLocation.locationID)"
            )
            return existingLocation
        }

        // Create a new location if no existing one was found
        print("No matching existing location found, creating new one")
        return try await createNewLocation(
            name: name,
            coordinates: coordinates,
            description: description,
            address: locationAddress,
            apiService: apiService
        )
    }

    /// Helper method to create a new location
    private static func createNewLocation(
        name: String,
        coordinates: CLLocationCoordinate2D,
        description: String?,
        address: String,
        apiService: StaySafeAPIService
    ) async throws -> Location {
        // Get postcode for the location
        let postcode =
            await fetchPostcode(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            ) ?? "XXX XXX"  // Restore the fallback value which the API might expect

        var locationName = name
        if name.contains(",") || (name.count > 30 && address.count > 5) {
            locationName = extractSimplifiedLocationName(from: address.isEmpty ? name : address)
            if locationName.count < 5,
                let locality =
                    (await reverseGeocode(
                        latitude: coordinates.latitude, longitude: coordinates.longitude))
                    .placemark?.locality
            {
                locationName += " in \(locality)"
            }
        }

        // Create a better description if none provided
        var locationDescription = description
        if locationDescription == nil || locationDescription == "Destination for trip" {
            locationDescription = extractLocationDescription(from: address)
        }

        // Create location object
        let newLocation = Location(
            locationID: 1,  // Server will assign the real ID - keep this as 1 for API compatibility
            locationName: locationName.prefix(60).description,  // Keep length limitation
            locationDescription: locationDescription?.prefix(100).description
                ?? "Location created automatically",
            locationAddress: address.isEmpty ? "Address unavailable" : address,  // Ensure address isn't empty
            locationPostcode: postcode,
            locationLatitude: coordinates.latitude,
            locationLongitude: coordinates.longitude
        )

        print("Creating new location: \(locationName) with address: \(address)")

        do {
            let createdLocation = try await apiService.createLocation(location: newLocation)
            print("Successfully created new location with ID: \(createdLocation.locationID)")
            return createdLocation
        } catch {
            // Add better error logging
            print("Error creating location: \(error.localizedDescription)")

            if let apiError = error as? APIError {
                print("API Error details: \(apiError.description)")
            }

            // If all else fails, throw the original error
            throw error
        }
    }

}
