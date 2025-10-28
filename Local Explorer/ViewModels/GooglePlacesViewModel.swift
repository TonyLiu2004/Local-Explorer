//
//  GooglePlacesViewModel.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation
import CoreLocation
import SwiftUI

class GooglePlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var photos: [String: UIImage] = [:]  // photo_reference -> image
    @Published var errorMessage: String? = nil
    
    private let service = GooglePlacesService()
    
    // MARK: - Nearby Places
    func fetchNearbyPlaces(lat: Double, lon: Double, radius: Int = 100, keyword: String? = nil, type: String? = nil) {
        service.searchPlaces(lat: lat, lon: lon, radius: radius, keyword: keyword, type: type) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPlaces):
                    self?.places = fetchedPlaces
                    self?.fetchPhotosForPlaces(fetchedPlaces)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Fetch photos for all places
    private func fetchPhotosForPlaces(_ places: [Place]) {
        for place in places {
            guard let photoReference = place.photos?.first?.photo_reference else { continue }
            if photos[photoReference] != nil { continue } // already cached

            service.fetchPhoto(photoReference: photoReference) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self?.photos[photoReference] = image
                    case .failure(let error):
                        print("Failed to fetch photo: \(error)")
                    }
                }
            }
        }
    }
    // Helper to get photo for a specific place
    func getPhoto(for place: Place) -> UIImage? {
        let photoref = place.photos?.first?.photo_reference
        guard let photoReference = photoref else {
            print("photoReference is nil")
            return nil
        }
//        print("got photoref")
        return photos[photoReference]
    }
}

