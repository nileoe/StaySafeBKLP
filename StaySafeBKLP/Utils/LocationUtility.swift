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

        // Create location object
        let newLocation = Location(
            locationID: 1,  // Server will assign the real ID - keep this as 1 for API compatibility
            locationName: name.prefix(60).description,  // Keep length limitation
            locationDescription: description?.prefix(100).description
                ?? "Location created automatically",
            locationAddress: address.isEmpty ? "Address unavailable" : address,  // Ensure address isn't empty
            locationPostcode: postcode,
            locationLatitude: coordinates.latitude,
            locationLongitude: coordinates.longitude
        )

        print("Creating new location: \(name) with address: \(address)")

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
