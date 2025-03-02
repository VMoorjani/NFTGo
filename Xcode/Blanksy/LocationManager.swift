//
//  LocationManager.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import Foundation
import CoreLocation
import MapKit

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let baseURL = "http://ec2-35-170-185-57.compute-1.amazonaws.com"
    
    // Simple in-memory image cache keyed by NFT UUID
    private var imageCache: [UUID: UIImage] = [:]
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Array of pins fetched from the API
    @Published var pins: [MapPin] = []
    
    // Store the closest pin (if within threshold)
    @Published var closestPin: MapPin?
    
    // Image data for the newest closest pin
    @Published var closestPinImage: UIImage? = nil
    
    // Published property to drive UI for showing the nearby alert
    @Published var showNearbyAlert: Bool = false
    
    // Last location that triggered a points fetch
    private var lastFetchedLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let currentLocation = location
        
        DispatchQueue.main.async {
            // Update the map region
            self.region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            // Update nearby alert and closest pin.
            self.isNFTNearby()
            
            // Only fetch new points if moved more than 1 mile (~1609 meters)
            let fetchThreshold: CLLocationDistance = 1609.34
            if let lastLocation = self.lastFetchedLocation {
                if currentLocation.distance(from: lastLocation) >= fetchThreshold {
                    self.lastFetchedLocation = currentLocation
                    self.fetchPoints(for: currentLocation.coordinate)
                }
            } else {
                self.lastFetchedLocation = currentLocation
                self.fetchPoints(for: currentLocation.coordinate)
            }
        }
    }
    
    func isNFTNearby() {
        print("Running isNFTNearby")
        // 0.1 miles in meters
        let thresholdMeters = 0.1 * 1609.34
        let currentLocation = CLLocation(latitude: self.region.center.latitude, longitude: self.region.center.longitude)
        
        // Filter pins that are within the threshold
        let nearbyPins = self.pins.filter { pin in
            let pinLocation = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
            return currentLocation.distance(from: pinLocation) <= thresholdMeters
        }
        
        // Update the alert flag
        self.showNearbyAlert = !nearbyPins.isEmpty
        
        // Determine and store the closest pin if any exist
        if let closest = nearbyPins.min(by: { pin1, pin2 in
            let distance1 = currentLocation.distance(from: CLLocation(latitude: pin1.latitude, longitude: pin1.longitude))
            let distance2 = currentLocation.distance(from: CLLocation(latitude: pin2.latitude, longitude: pin2.longitude))
            return distance1 < distance2
        }) {
            self.closestPin = closest
            print("Closest pin: \(closest)")
            // Fetch image for the new closest pin
            self.fetchImageForPin(for: closest)
        } else {
            self.closestPin = nil
            self.closestPinImage = nil // Clear image if no pin is nearby
        }
    }
    
    func fetchImageForPin(for pin: MapPin) {
        // Check if image is already cached
        print("fetchImage was called")
        if let cachedImage = imageCache[pin.id] {
            DispatchQueue.main.async {
                self.closestPinImage = cachedImage
            }
            return
        }
        print(pin.id.uuidString.lowercased())
        // Build the URL for the NFT image using the pin's id.
        guard let url = URL(string: "\(baseURL)/nft/\(pin.id.uuidString.lowercased())") else {
            print("Invalid URL for image fetch")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("No image data returned or unable to convert data to UIImage")
                return
            }
            
            // Cache the image using the pin's id
            DispatchQueue.main.async {
                self.imageCache[pin.id] = image
                self.closestPinImage = image
            }
        }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update error: \(error)")
    }
    
    struct NearbyPointsResponse: Codable {
        let success: Bool
        let nearby_nfts: [MapPin]
        let count: Int
    }
    
    func fetchPoints(for coordinate: CLLocationCoordinate2D) {
        print("Running fetch points")
        guard let url = URL(string: "\(baseURL)/nearby_points?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("API error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned from API")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(NearbyPointsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.pins = decodedResponse.nearby_nfts
                    self.isNFTNearby()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}



