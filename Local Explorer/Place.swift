//
//  Place.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation

struct GooglePlacesResponse: Decodable {
    let results: [Place]
}

struct PlaceResponse: Decodable {
    let html_attributions: [String]
    let results: [Place]
    let status: String
}

struct Place: Decodable, Identifiable {
    let place_id: String
    let geometry: Geometry?
    let icon: String?
    let icon_background_color: String?
    let icon_mask_base_uri: String?
    let name: String
    let business_status: String?
    let photos: [Photo]?
    
    var id: String { place_id } // use place_id as the unique identifier
    
    let plus_code: PlusCode?
    let price_level: Int?
    let rating: Double?
    let reference: String?
    let scope: String?
    let types: [String]?
    let user_ratings_total: Int?
    let vicinity: String?
    let international_phone_number: String?
}

extension Place {
    static let placeholder = Place(
        place_id: "placeholder",
        geometry: nil,
        icon: nil,
        icon_background_color: nil,
        icon_mask_base_uri: nil,
        name: "No places found",
        business_status: nil,
        photos: nil,
        plus_code: nil,
        price_level: nil,
        rating: nil,
        reference: nil,
        scope: nil,
        types: nil,
        user_ratings_total: nil,
        vicinity: nil,
        international_phone_number: nil
    )
}

struct Geometry: Decodable {
    let location: Location
    let viewport: Viewport?
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}

struct Viewport: Decodable {
    let northeast: Coordinate
    let southwest: Coordinate
}

struct Coordinate: Decodable {
    let lat: Double
    let lng: Double
}

struct Photo: Decodable {
    let height: Int
    let html_attributions: [String]
    let photo_reference: String
    let width: Int
}

struct PlusCode: Decodable {
    let compound_code: String?
    let global_code: String?
}
