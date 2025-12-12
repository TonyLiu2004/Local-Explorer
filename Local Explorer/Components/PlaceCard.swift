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
    let onTap: () -> Void
    @StateObject var viewModel = GooglePlacesViewModel()
    @Environment(\.modelContext) private var modelContext

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
    
    @State var firstURL: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: self.firstURL) { phase in
                switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 360, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 340, height: 200)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal)
                    case .failure:
                        Color.gray
                            .frame(width: 360, height: 200)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                }
            }
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
                    Spacer()
                }
                .frame(maxWidth: 300)
                
                var status: AttributedString {
                    if let open = place.current_opening_hours?.open_now {
                        var s = AttributedString(open ? "Open" : "Closed")
                        s.foregroundColor = open ? .green : .red
                        return s
                    } else {
                        return AttributedString("Hours unavailable")
                    }
                }

                Text(status)
                    .captionStyle()

                Text("Price: \(priceText)")
                    .captionStyle()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)

//            if let photoRef = place.photos?.first?.photo_reference {
//                let url = viewModel.photosURL[photoRef]

        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .frame(width: 360)  // Fixed width for horizontal scrolling
        .cardStyle()
        .onTapGesture {
            onTap()
        }
        .task {
            viewModel.fetchStoredPlaces(context: modelContext)
            
            if viewModel.storedPhotoURL[place.place_id] != nil {
                self.firstURL = viewModel.storedPhotoURL[place.place_id]?.first ?? URL(string: "about:blank")!
                print("Loaded first image from storage.")
            } else {
                print("places images not in cache, fetch images.")
                viewModel.fetchPhotosForPlaces([place])
            }
        }
        .onChange(of: viewModel.storedPhotoURL) { _ in
            if let cachedUrls = viewModel.storedPhotoURL[place.place_id] {
                self.firstURL = cachedUrls.first
                print("firstURL updated from storedPhotoURL cache.")
            }
        }
        .onChange(of: viewModel.photosURL) { _ in
            if let photo = viewModel.photosURL[place.photos?.first?.photo_reference ?? ""] {
                self.firstURL = photo
            }
        }
        

    }
}

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
