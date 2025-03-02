//
//  NFTData.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/2/25.
//

import Foundation
import UIKit
import CoreLocation

struct NFTData: Identifiable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let imageData: UIImage?
    let name: String
    let description: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
