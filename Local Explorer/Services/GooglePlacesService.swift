//
//  GooglePlacesService.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation
import CoreLocation
import UIKit

class GooglePlacesService {
    private let apiKey = Secrets.GooglePlacesKey
    private let session = URLSession.shared
    
    // MARK: - 1. Nearby search
    func searchPlaces(
        lat: Double,
        lon: Double,
        radius: Int = 100,
        keyword: String? = nil,
        type: String? = nil,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=\(radius)&key=\(apiKey)"
        
        if let keyword = keyword {
            urlString += "&keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        if let type = type {
            urlString += "&type=\(type.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }

        guard let url = URL(string: urlString) else { return }

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(PlaceResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchPhoto(photoReference: String, maxWidth: Int = 400, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photo_reference=\(photoReference)&key=\(apiKey)"

        guard let url = URL(string: urlString) else { return }

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let image = UIImage(data: data) else { return }
            completion(.success(image))
        }
        .resume()
    }
}
