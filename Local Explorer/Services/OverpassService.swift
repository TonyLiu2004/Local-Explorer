//
//  OverpassService.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/17/25.
//

import Foundation

func overpassCall(lat: Double, lon: Double, completion: @escaping (String?) -> Void) {
    let query = "[out:json];node(around:1000,\(lat),\(lon))[amenity=restaurant][cuisine=italian];out;"
    let urlString = "https://overpass-api.de/api/interpreter?data=" + query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    print(urlString)
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data, let text = String(data: data, encoding: .utf8) {
            completion(text)
        } else {
            completion(nil)
        }
    }.resume()
}
