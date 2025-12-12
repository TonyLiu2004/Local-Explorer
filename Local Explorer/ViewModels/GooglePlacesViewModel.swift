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
    @Published var storedPlaceDetailsList: [PlaceDetails] = []
    @Published var photos: [String: UIImage] = [:]  // photo_reference -> image
    @Published var photosURL: [String: URL] = [:] // photoref -> URL
    @Published var allPhotoURL: [String: [URL]] = [:] //place_id -> [photoURls]
    @Published var storedPhotoURL: [String: [URL]] = [:]
    @Published var errorMessage: String? = nil
    
    private let service = GooglePlacesService()

    
    // SwiftData functions
    func fetchStoredPlaces(context: ModelContext) {
        let stored = fetchStoredPlacesFromContext(context: context)

        // Convert StoredPlaceDetails -> PlaceDetails (or just store StoredPlaceDetails if your List can handle it)
        for storedPlace in stored {
            if storedPlaceDetailsList.contains(where: { $0.place_id == storedPlace.place_id }) {
                continue //don't add if already in list
            }
            let urls = storedPlace.photo_URL_strings.compactMap { URL(string: $0) }
            self.storedPhotoURL[storedPlace.place_id] = urls
            
            let place_detail = PlaceDetails(
                place_id: storedPlace.place_id,
                name: storedPlace.name,
                formatted_address: storedPlace.formatted_address,
                international_phone_number: nil,
                formatted_phone_number: storedPlace.formatted_phone_number,
                website: nil,
                price_level: nil,
                rating: storedPlace.rating,
                user_ratings_total: storedPlace.user_ratings_total,
                types: nil,
                geometry: Geometry(location: Location(lat: storedPlace.latitude, lng: storedPlace.longitude), viewport: nil),
                photos: nil,
                opening_hours: nil,
                current_opening_hours: OpeningHours(open_now: nil, periods: nil, weekday_text: storedPlace.weekdayText),
                reviews: nil,
                business_status: nil,
                vicinity: nil,
                editorial_summary: EditorialSummary(language: "en", overview: storedPlace.editorial_overview),
                url: nil,
                delivery: nil,
                dine_in: nil,
                takeout: nil,
                serves_breakfast: nil,
                serves_brunch: nil,
                serves_lunch: nil,
                serves_dinner: nil,
                serves_beer: nil,
                serves_wine: nil,
                serves_vegetarian_food: nil,
                reservable: nil,
                wheelchair_accessible_entrance: nil
            )
            storedPlaceDetailsList.append(place_detail)
        }
        print("Fetched \(storedPlaceDetailsList.count) places that were stored")
    }
    
    func fetchStoredPlacesFromContext(context: ModelContext) -> [StoredPlaceDetails] {
        let descriptor = FetchDescriptor<StoredPlaceDetails>()
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
    
    func savePlace(_ place: PlaceDetails, context: ModelContext) {
        do{
            let all = try context.fetch(FetchDescriptor<StoredPlaceDetails>())
            
            //delete old context if it exists
            if let existing = all.first(where: { $0.place_id == place.place_id }) {
                print("deleted dupe")
                context.delete(existing)
            }
            
            let urls = place.photos?
                .compactMap { photosURL[$0.photo_reference] } ?? []
            let urlStrings = urls.map { $0.absoluteString }
            let stored = StoredPlaceDetails(from: place, photoURLs: urlStrings)
            context.insert(stored)
            
            try context.save()
            storedPlaceDetailsList.append(place)
            self.storedPhotoURL[place.place_id] = urls
            print("Saved \(place.name) place to SwiftData.")
        } catch {
            print("couldnt fetch all")
        }
    }
    
    func removePlace(_ place: PlaceDetails, context: ModelContext) {
        do {
            let all = try context.fetch(FetchDescriptor<StoredPlaceDetails>())
            
            if let existing = all.first(where: { $0.place_id == place.place_id }) {
                context.delete(existing)
                try context.save()
                storedPlaceDetailsList.removeAll { $0.place_id == place.place_id }
                print("Removed \(place.name) from SwiftData.")
            } else {
                print("Place not found, nothing to remove.")
            }
            
        } catch {
            print("Failed to fetch or remove place: \(error)")
        }
    }

    
    //fetch single place, used to check if a place is already stored
    func getStoredPlace(placeID: String, context: ModelContext) -> StoredPlaceDetails? {
        let stored = fetchStoredPlacesFromContext(context: context)
        return stored.first(where: { $0.place_id == placeID })
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
            
            DispatchQueue.main.async {
                self.placeDetailsList = samplePlaceDetails
                let testURLs = [
                        URL(string: "https://lh3.googleusercontent.com/place-photos/AEkURDwmpaEZr4KRhmx5FsxTqIxFiCRvTSIQ56KUk2EOEINMxDcPHEGCwjKNCAr3yi8SRM5wmgMAueZTnSL6X58VMlqn8_zE7KWks2bbO2-2FlFpRc85AFjpmaNQUHB4dXP4QrEZjS2V8md-xFh0mg=s1600-w400"),
                        URL(string: "https://lh3.googleusercontent.com/places/ANXAkqE-O3ShdY8ES3eAmKlv9A7-kQ6L92hl8khsEfr-n1OkcsmvEG37XlNpLuId3FwV49StANdj5x2TPcsanunbNAP1gQ-BLoeYJ6I=s1600-w400"),
                        URL(string: "https://lh3.googleusercontent.com/places/ANXAkqFCkTM_vqQ83QGsRp3o0BKcIHaUKeCpNl7DS9S9CN22AX_EC88j8fO4atMNtUTPMwRKIZ-8v8p7hvNyrw4np63mNXtHpE1mSp4=s1600-w400"),
                        URL(string: "https://ghi.com")
                ]
                for place in self.placeDetailsList{
                    guard let photos = place.photos, !photos.isEmpty else {
                        print("No photos for \(place.name)")
                        continue
                    }
                    let count = min(photos.count, testURLs.count)
                    for i in 0..<count {
                        let ref = photos[i].photo_reference
                        self.photosURL[ref] = testURLs[i]
                    }
                    
                }
            }
        } catch {
            print("Failed to load sample places: \(error)")
        }
    }
    
    // Nearby Places
    func fetchNearbyPlaces(lat: Double, lon: Double, radius: Int = 100, keyword: String? = nil, type: String? = nil, replace: Bool = false) {
        loadSamplePlaces()
//        if radius == 200 {
//            print("radius reached 200 in fetchnearby, ending")
//            return
//        }
//        service.searchPlaces(lat: lat, lon: lon, radius: radius, keyword: keyword, type: type) { [weak self] result in
//            guard let self = self else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let fetchedPlaces):
////                    self?.places = fetchedPlaces
////                    self.fetchDetailsForPlaces(fetchedPlaces)
//                    if replace {
//                        print("replacing in fetchnearbyplaces")
//                        self.places = fetchedPlaces
//                        //self.fetchDetailsForPlaces(fetchedPlaces, replace: true)
//                        self.placeDetailsList = []
//                        self.keepFetchingUntilResult(fetchedPlaces, lat: lat, lon: lon, radius: radius, keyword: keyword, type: type, replace: true)
//                    } else {
//                        print("filtering in fetchnearbyplaces")
//                        // filter out places that are already in placeDetailsList
//                        let newPlacesToFetch = fetchedPlaces.filter { newPlace in
//                            !self.placeDetailsList.contains(where: { existingDetail in
//                                existingDetail.place_id == newPlace.place_id
//                            })
//                        }
//                        
//                        //self.fetchDetailsForPlaces(newPlacesToFetch)
//                        self.keepFetchingUntilResult(newPlacesToFetch, lat: lat, lon: lon, radius: radius, keyword: keyword, type: type)
//                    }
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        } //end service
    }
    
    func printPlaceDetailsList() {
        print("Place details list:")
        for place in placeDetailsList{
            print(place.name)
        }
    }
    
    func keepFetchingUntilResult(_ places: [Place], lat: Double, lon: Double, radius: Int = 100, keyword: String? = nil, type: String? = nil, replace: Bool = false) {
        var placesToFetchDetailsFor = places
        if !replace {
            print("not replacing, filtering in keepFetchingUntilResult")
            placesToFetchDetailsFor = places.filter { newPlace in
                !self.placeDetailsList.contains(where: { existingDetail in
                    existingDetail.place_id == newPlace.place_id
                })
            }
        } else {
            print("replacing in keepfetching")
        }

        // no new places to fetch
        guard !placesToFetchDetailsFor.isEmpty else {
            print("no new places to fetch. increasing range by 20")
            fetchNearbyPlaces(lat: lat, lon: lon, radius: radius+20, keyword: keyword, type: type, replace: replace)
            return
        }
        
        fetchDetailsForPlaces(places, replace: replace)
    }
    
    private func fetchDetailsForPlaces(_ places: [Place], replace: Bool = false) {
        let group = DispatchGroup()
        var fetchedDetails: [PlaceDetails] = []
        var fetchError: Error? = nil
        
        for place in places {
            let placeId = place.place_id
            group.enter()
            service.fetchPlace(placeId: placeId) { result in
                switch result {
                case .success(let placeDetails):
                    print("fetched \(placeDetails.name)")
                    
                     fetchedDetails.append(placeDetails)
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
            
            if replace {
                print("replacing in fetchDetails for places")
                self.placeDetailsList = fetchedDetails
            } else {
                print("appending in fetchDetails for places")
                self.placeDetailsList.append(contentsOf: fetchedDetails)
            }
            
            self.fetchPhotosForPlaces(fetchedDetails)
        }
    }
    
    
    // Fetch photos for all places (only first photos)
    func fetchPhotosForPlaces(_ places: [PlaceDetails]) {
        for place in places {
            guard let photoReference = place.photos?.first?.photo_reference else {
                print("No photos for \(place.name)")
                continue
            }
            getPhotoURL(ref: photoReference)
        }
    }
    
    func mapStoredPhotoURLs(_ place: PlaceDetails) {
        print("mapStoredPhotoURLs called")
        guard let cachedUrlStrings = self.storedPhotoURL[place.place_id] else {
            print("Error: No photo URL strings found in cache for place: \(place.name)")
            return
        }
        
        if let currentPhotos = place.photos {
            for (index, photo) in currentPhotos.prefix(cachedUrlStrings.count).enumerated() {
                let ref = photo.photo_reference
                let urlString = cachedUrlStrings[index]
                self.photosURL[ref] = urlString
            }
        }
    }
    
    func fetchAllPhotos(_ place: PlaceDetails) {
        if let stored = storedPlaceDetailsList.first(where: { $0.place_id == place.place_id }) {
            print("fetchAllPhotos: Place already stored: \(stored.name)")
            mapStoredPhotoURLs(place)
            return
        }
        return // for testing, just return
        guard let photos = place.photos else {
            print("no photos for \(place)")
            return
        }
        var count = 1
        for photo in photos {
            let ref = photo.photo_reference
            if photosURL[ref] != nil {
                count = count + 1
                continue
            }
            print("getPhotoURL for \(place.name)")
            getPhotoURL(ref: ref)
        }
        print("skipped \(count) calls to getPhotoURL for \(place.name)")
    }

    func getPhotoURL(ref: String) -> Void {
        if self.photosURL[ref] != nil {
            print("getPhotoURL called but ref already exists")
            return
        }
        service.fetchPhotoURL(photoReference: ref) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self?.photosURL[ref] = url
                case .failure(let error):
                    print("Failed to fetch photo: \(error)")
                }
            }
        }
    }
}

