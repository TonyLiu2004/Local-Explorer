//
//  PlaceCard.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/28/25.
//

import SwiftUI
import CoreLocation

struct PlaceCard: View {
//    let place: Place
    let place: PlaceDetails
    let location: CLLocation?
    @StateObject var viewModel = GooglePlacesViewModel()

    var priceText: String {
        guard let price = place.price_level else { return "N/A" }
        switch price {
        case 0: return "Free"
        case 1: return "$0–20"
        case 2: return "$20–100"
        case 3: return "$100+"
        case 4: return "$200+"
        default: return "N/A"
        }
    }
    var placeCoords: CLLocation {
        let long = place.geometry.location.lng
        let lat = place.geometry.location.lat
        return CLLocation(latitude: lat, longitude: long)
    }
    var distanceText: String {
        if let loc = location
        {
            let distanceMeters = loc.distance(from: placeCoords)
            let distanceMiles = distanceMeters / 1609.34
            
            if distanceMiles < 0.1 {
                let feet = distanceMeters * 3.28084
                return "\(Int(feet)) ft"
            } else {
                return String(format: "%.1f mi", distanceMiles)
            }
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(place.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    if let rating = place.rating {
                        Text("\(String(format: "%.1f", rating)) ⭐️ (\(place.user_ratings_total ?? 0))  -")
                            .captionStyle()
                    }
                    Text(distanceText)
                        .captionStyle()
                    if let types = place.types {
                        Text(types.joined(separator: ", "))
                            .captionStyle()
                    }
                }
                .frame(maxWidth: 300)
            }
            .onAppear {
                print(place.name, place.place_id)
            }
            .padding([.leading, .trailing], 8)
            
            if let current = place.current_opening_hours {
                Text(current.open_now == true ? "Open" : "Closed")
                    .captionStyle()
                    .padding(.horizontal, 8)
            } else {
                Text("Hours unavailable")
                    .captionStyle()
                    .padding(.horizontal, 8)
            }
            Text("Price: \(priceText)")
                .captionStyle()
                .padding(.horizontal, 8)

            if let image = viewModel.getPhoto(for: place) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 360, height: 200)
                    .clipped()
                    .cornerRadius(10)

            } else {
                Color.gray
                    .frame(width: 360, height: 200)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .frame(width: 360)  // Fixed width for horizontal scrolling
        .cardStyle()

    }
}

#Preview {
    ContentView()
}
