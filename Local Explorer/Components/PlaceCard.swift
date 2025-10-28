//
//  PlaceCard.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/28/25.
//

import SwiftUI

struct PlaceCard: View {
    let place: Place
    @StateObject var viewModel = GooglePlacesViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 8) {
                // Place name
                Text(place.name)
                    .font(.headline)
                    .lineLimit(1) // optional: keep it on one line

                // Rating and types in smaller caption
                if let rating = place.rating, let types = place.types {
                    Text("⭐️ \(String(format: "%.1f", rating)) (\(place.user_ratings_total ?? 0)) - \(types.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else if let rating = place.rating {
                    Text("⭐️ \(String(format: "%.1f", rating)) (\(place.user_ratings_total ?? 0))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else if let types = place.types {
                    Text(types.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding([.leading, .trailing], 8)
//            if let photos = place.photos {
//                ForEach(photos, id: \.photo_reference) { photo in
//                    Text(photo.photo_reference)
//                        .font(.caption)
//                        .foregroundColor(.gray)	
//                }
//            }
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
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    ContentView()
}
