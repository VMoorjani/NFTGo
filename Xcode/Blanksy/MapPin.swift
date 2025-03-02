//
//  MapPin.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import Foundation
import CoreLocation
import UIKit

struct MapPin: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


