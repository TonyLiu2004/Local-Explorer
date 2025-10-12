//
//  GooglePlacesService.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation
import CoreLocation

func googlePlacesCall(
    lat: Double,
    lon: Double,
    radius: Int = 100,
    keyword: String? = nil,
    type: String? = nil,
    completion: @escaping (String?) -> Void	
) {
    let apiKey =  Secrets.GooglePlacesKey
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=\(radius)&key=\(apiKey)"

    if let keyword = keyword {
        urlString += "&keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    }
    if let type = type {
        urlString += "&type=\(type.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    }

    print("Google Places Request: \(urlString)")

    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            print("Request failed: \(error)")
            completion(nil)
            return
        }

        guard let data = data, let text = String(data: data, encoding: .utf8) else {
            completion(nil)
            return
        }

        completion(text)
    }.resume()
}
