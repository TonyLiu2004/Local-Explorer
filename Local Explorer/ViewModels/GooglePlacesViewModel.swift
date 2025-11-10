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
    @Published var placeDetailsList: [PlaceDetails] = []
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
                    self?.fetchDetailsForPlaces(fetchedPlaces)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchDetailsForPlaces(_ places: [Place]) {
          let group = DispatchGroup()
          var details: [PlaceDetails] = []
          var fetchError: Error? = nil
          
          for place in places {
              let placeId = place.place_id
              group.enter()
              service.fetchPlace(placeId: placeId) { result in
                  switch result {
                  case .success(let placeDetails):
                      if let photos = placeDetails.photos, !photos.isEmpty { //exclude places with no photos
                          details.append(placeDetails)
                      }
                  case .failure(let error):
                      fetchError = error
                  }
                  group.leave()
              }
          }
          
          group.notify(queue: .main) {
              if let error = fetchError {
                  self.errorMessage = error.localizedDescription
              }
              // All fetched place details
              self.placeDetailsList = details
              
              // Fetch photos after placeDetailsList is updated
              self.fetchPhotosForPlaces(details)
          }
      }
    
    // MARK: - Fetch photos for all places (only first photos)
    private func fetchPhotosForPlaces(_ places: [PlaceDetails]) {
        for place in places {
            guard let photoReference = place.photos?.first?.photo_reference else {
                print("No photos for \(place.name)")
                continue
            }
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
    
    func getPhoto(for place: PlaceDetails) -> UIImage? {
        let photoref = place.photos?.first?.photo_reference
        guard let photoReference = photoref else {
            return nil
        }
        return photos[photoReference]
    }

}

