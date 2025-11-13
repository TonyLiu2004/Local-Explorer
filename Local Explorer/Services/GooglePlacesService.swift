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
    
    let excludedTypes: [String] = ["political", "neighborhood", "parking"]
    
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
//        print(urlString)
        guard let url = URL(string: urlString) else { return }

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(PlaceResponse.self, from: data)
                let filtered = response.results.filter { place in
                    guard let types = place.types else { return true } // keep if types is nil
                    return !types.contains(where: { self.excludedTypes.contains($0) })
                }
                completion(.success(filtered))
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
    
    func fetchPhotoURL(photoReference: String, maxWidth: Int = 400, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photo_reference=\(photoReference)&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Google redirects to the real image URL
            if let httpResponse = response as? HTTPURLResponse,
               let finalURL = httpResponse.url {
                completion(.success(finalURL))
            } else {
                completion(.failure(NSError(domain: "NoRedirect", code: -1, userInfo: nil)))
            }
        }
        task.resume()
    }

    
    //Fetches more detailed info about a specific place based on placeId
    func fetchPlace(placeId: String, completion: @escaping (Result<PlaceDetails, Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
                completion(.success(response.result))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }

    struct PlaceDetailsResponse: Decodable {
        let result: PlaceDetails
    }

}
