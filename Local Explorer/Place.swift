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
//    let geometry: Geometry?
//    let icon: String?
//    let icon_background_color: String?
//    let icon_mask_base_uri: String?
//    let name: String
//    let business_status: String?
//    let photos: [Photo]?
    
    var id: String { place_id } // use place_id as the unique identifier
    
//    let plus_code: PlusCode?
//    let price_level: Int?
//    let rating: Double?
//    let reference: String?
//    let scope: String?
    let types: [String]?
//    let user_ratings_total: Int?
//    let vicinity: String?
//    let international_phone_number: String?
}

//Place holder for Place
extension Place {
    static let placeholder = Place(
        place_id: "placeholder",
//        geometry: nil,
//        icon: nil,
//        icon_background_color: nil,
//        icon_mask_base_uri: nil,
//        name: "No places found",
//        business_status: nil,
//        photos: nil,
//        plus_code: nil,
//        price_level: nil,
//        rating: nil,
//        reference: nil,
//        scope: nil,
        types: nil,
//        user_ratings_total: nil,
//        vicinity: nil,
//        international_phone_number: nil
    )
}

struct PlaceDetails: Decodable, Identifiable {
    var id: String { place_id }
    
    let place_id: String
    let name: String
    let formatted_address: String?
    let international_phone_number: String?
    let formatted_phone_number: String?
    let website: String?
    let price_level: Int?
    let rating: Double?
    let user_ratings_total: Int?
    let types: [String]?
    let geometry: Geometry
    let photos: [Photo]?
    let opening_hours: OpeningHours?
    let current_opening_hours: OpeningHours?
    let reviews: [Review]?
    let business_status: String?
    let vicinity: String?
    let editorial_summary: EditorialSummary?
    let url: String?
    let delivery: Bool?
    let dine_in: Bool?
    let takeout: Bool?
    let serves_breakfast: Bool?
    let serves_brunch: Bool?
    let serves_lunch: Bool?
    let serves_dinner: Bool?
    let serves_beer: Bool?
    let serves_wine: Bool?
    let serves_vegetarian_food: Bool?
    let reservable: Bool?
    let wheelchair_accessible_entrance: Bool?
}

extension PlaceDetails {
    static let placeholder = PlaceDetails(
        place_id: "placeholder",
        name: "No place details",
        formatted_address: nil,
        international_phone_number: nil,
        formatted_phone_number: nil,
        website: nil,
        price_level: nil,
        rating: nil,
        user_ratings_total: nil,
        types: nil,
        geometry: Geometry(
            location: Location(lat: 0.0, lng: 0.0),
            viewport: nil
        ),
        photos: nil,
        opening_hours: nil,
        current_opening_hours: nil,
        reviews: nil,
        business_status: nil,
        vicinity: nil,
        editorial_summary: nil,
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

struct OpeningHours: Decodable {
    let open_now: Bool?
    let periods: [Period]?
    let weekday_text: [String]?
}

struct Period: Decodable {
    let open: DayTime
    let close: DayTime?
}

struct DayTime: Decodable {
    let day: Int?
    let time: String?
    let date: String? // Some fields like current_opening_hours include `date`
}

struct Review: Decodable {
    let author_name: String
    let author_url: String?
    let profile_photo_url: String?
    let rating: Double?
    let relative_time_description: String?
    let text: String?
    let time: Int?
    let language: String?
    let original_language: String?
    let translated: Bool?
}

struct EditorialSummary: Decodable {
    let language: String?
    let overview: String?
}
