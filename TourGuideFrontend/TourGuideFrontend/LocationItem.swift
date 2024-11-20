//
//  LocationItem.swift
//  TourGuideFrontend
//
//  Created by Alex Sieni on 11/20/24.
//

import SwiftUI
import MapKit

struct LocationItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}
