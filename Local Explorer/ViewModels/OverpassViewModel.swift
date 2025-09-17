//
//  OverpassViewModel.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/17/25.
//

import Foundation
import CoreLocation

class OverpassViewModel: ObservableObject {
    @Published var overpassJSON: String? = nil

    func fetchRestaurants(lat: Double, lon: Double) {
        overpassCall(lat: lat, lon: lon) { json in
            DispatchQueue.main.async {
                self.overpassJSON = json
            }
        }
    }
}
