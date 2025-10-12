//
//  GooglePlacesViewModel.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation
import CoreLocation

class GooglePlacesViewModel: ObservableObject {
    @Published var googlePlacesJSON: String? = nil
    @Published var decoded: GooglePlacesResponse? = nil  // decoded data

    func fetchNearbyPlaces(lat: Double, lon: Double, radius: Int = 100) {
        googlePlacesCall(lat: lat, lon: lon, radius: radius) { [weak self] json in
            DispatchQueue.main.async {
                self?.googlePlacesJSON = json
                self?.decodeGooglePlacesJSON()
            }
        }
    }
    private func decodeGooglePlacesJSON() {
        guard let jsonString = googlePlacesJSON,
              let data = jsonString.data(using: .utf8) else { return }
        decoded = try? JSONDecoder().decode(GooglePlacesResponse.self, from: data)
    }
}
