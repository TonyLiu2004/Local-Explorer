//
//  Place.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation

struct GooglePlacesResponse: Codable {
    let results: [Place]
}

struct Place: Codable, Identifiable {
    let place_id: String
    let name: String
    
    var id: String { place_id } // use place_id as the unique identifier
}
