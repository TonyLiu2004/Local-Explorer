//
//  PlaceDetailsModel.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/12/25.
//

import SwiftData

@Model
class StoredPlaceDetails {
    var place_id: String
    var name: String
    var formatted_address: String?
    var rating: Double?
    var user_ratings_total: Int?
    var latitude: Double
    var longitude: Double
    var photo_reference: String?
    var editorial_overview: String?
    var photoURLs: [String] = []

    init(from place: PlaceDetails, photoURLs: [String] = []) {
        self.place_id = place.place_id
        self.name = place.name
        self.formatted_address = place.formatted_address
        self.rating = place.rating
        self.user_ratings_total = place.user_ratings_total
        self.latitude = place.geometry.location.lat
        self.longitude = place.geometry.location.lng
        self.photo_reference = place.photos?.first?.photo_reference
        self.editorial_overview = place.editorial_summary?.overview
        self.photoURLs = photoURLs
    }
}
