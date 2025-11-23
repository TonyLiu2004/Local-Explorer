//
//  GooglePlacesViewModel.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation
import CoreLocation
import SwiftUI
import SwiftData

class GooglePlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var placeDetailsList: [PlaceDetails] = []
    @Published var photos: [String: UIImage] = [:]  // photo_reference -> image
    @Published var photosURL: [String: URL] = [:] // photoref -> URL
    @Published var allPhotoURL: [String: [URL]] = [:] //place_id -> [photoURls]
    @Published var errorMessage: String? = nil
    
    private let service = GooglePlacesService()
    			
    @Environment(\.modelContext) var modelContext
    
    // SwiftData functions
    func savePlaces(_ places: [PlaceDetails], context: ModelContext) {
        for place in places {
            let urls = allPhotoURL[place.place_id]?.map { $0.absoluteString } ?? []
            let stored = StoredPlaceDetails(from: place, photoURLs: urls)
            context.insert(stored)
        }

        do {
            try context.save()
            print("Saved \(places.count) places to SwiftData.")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
    
    func fetchStoredPlaces(context: ModelContext) -> [StoredPlaceDetails] {
        let descriptor = FetchDescriptor<StoredPlaceDetails>()
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }


    
    func loadSamplePlaces() {
        guard let url = Bundle.main.url(forResource: "placeDetailsSample", withExtension: "json") else {
            print("Failed to find sample data")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // Decode the JSON directly into PlaceDetails array
            let samplePlaceDetails = try decoder.decode([PlaceDetails].self, from: data)
            
            // Update your published properties on main thread
            DispatchQueue.main.async {
                self.placeDetailsList = samplePlaceDetails
                
                for place in self.placeDetailsList{
                    guard let first_photoref = place.photos?.first?.photo_reference else {
                        print("No photos for \(place.name)")
                        continue
                    }
                    let first_photo_url = URL(string: "https://lh3.googleusercontent.com/place-photos/AEkURDwmpaEZr4KRhmx5FsxTqIxFiCRvTSIQ56KUk2EOEINMxDcPHEGCwjKNCAr3yi8SRM5wmgMAueZTnSL6X58VMlqn8_zE7KWks2bbO2-2FlFpRc85AFjpmaNQUHB4dXP4QrEZjS2V8md-xFh0mg=s1600-w400")
                    self.photosURL[first_photoref] = first_photo_url
                    
                    //testing allPhotoURL
                    if let firstPhotoURL = first_photo_url {
                        self.allPhotoURL[place.place_id] = [firstPhotoURL]
                        
                        let testURLs = [
                                URL(string: "https://abc.com"),
                                URL(string: "https://def.com"),
                                URL(string: "https://ghi.com")
                        ]
                        self.allPhotoURL[place.place_id]?.append(contentsOf: testURLs.compactMap { $0 })
                    }                    
                    //end test Allphotourl
                    
                }
            }
        } catch {
            print("Failed to load sample places: \(error)")
        }
    }
    
    // MARK: - Nearby Places
    func fetchNearbyPlaces(lat: Double, lon: Double, radius: Int = 100, keyword: String? = nil, type: String? = nil) {
        loadSamplePlaces()
        
//        service.searchPlaces(lat: lat, lon: lon, radius: radius, keyword: keyword, type: type) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let fetchedPlaces):
//                    self?.places = fetchedPlaces
//                    self?.fetchDetailsForPlaces(fetchedPlaces)
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
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
            //normal photo fetch, directly as UIImage
//            service.fetchPhoto(photoReference: photoReference) { [weak self] result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let image):
//                        self?.photos[photoReference] = image
//                    case .failure(let error):
//                        print("Failed to fetch photo: \(error)")
//                    }
//                }
//            }
            
            service.fetchPhotoURL(photoReference: photoReference) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        self?.photosURL[photoReference] = url
                    case .failure(let error):
                        print("Failed to fetch photo: \(error)")
                    }
                }
            }
        }
    }
    
    func fetchAllPhotos(_ place: PlaceDetails) {
        guard let photos = place.photos else {
            print("no photos for \(place)")
            return
        }
        var allPhotos: [URL] = []
        for photo in photos {
            let ref = photo.photo_reference
            service.fetchPhotoURL(photoReference: ref) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        allPhotos.append(url)
                        self?.allPhotoURL[place.place_id] = allPhotos
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
    
    func getPhotoURL(for place: PlaceDetails) -> URL? {
        guard let photoRef = place.photos?.first?.photo_reference else {
            return nil
        }
        return photosURL[photoRef]
    }
}

