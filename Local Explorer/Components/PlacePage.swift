//
//  PlacePage.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/27/25.
//
import SwiftUI
import CoreLocation

struct PlacePage: View {
    let place: PlaceDetails
    let location: CLLocation?
    let onTap: () -> Void
    @StateObject var viewModel = GooglePlacesViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                //Start photos
                let urls = place.photos?
                .compactMap { viewModel.photosURL[$0.photo_reference] } ?? []
                
                ZStack {
                    ScrollView (.horizontal){
                        HStack{
                            ForEach(urls, id: \.self) { url in
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 300, height: 200)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    case .failure:
                                        EmptyView()
                                    @unknown default:
                                        Color.gray
                                            .frame(width: 360, height: 200)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 24){
                        Button {
                            let latitude = place.geometry.location.lat
                            let longitude = place.geometry.location.lng

                            // Google Maps URL scheme
                            if let url = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)&zoom=14") {
                                if UIApplication.shared.canOpenURL(url) {
                                    // Open Google Maps app
                                    UIApplication.shared.open(url)
                                } else if let webUrl = URL(string: "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)") {
                                    // Fallback to browser if Google Maps app not installed
                                    UIApplication.shared.open(webUrl)
                                }
                            }
                        } label: {
                            Image(systemName: "paperplane")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            if viewModel.storedPlaceDetailsList.contains(where: { $0.id == place.id }) {
                                viewModel.removePlace(place, context: modelContext)
                            } else {
                                viewModel.savePlace(place, context: modelContext)
                            }
                        } label: {
                            Image(systemName: viewModel.storedPlaceDetailsList.contains(where: { $0.id == place.id }) ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .frame(width: 24, height: 28)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                }
                //end Photos
                Spacer()
                //bottom texts vstack
                VStack {
                    Text(place.name)
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        var ratingText: AttributedString {
                            guard let rating = place.rating else { return AttributedString("") }

                            let full = Int(round(rating))

                            let stars =
                                String(repeating: "⭐️", count: full)

                            return AttributedString("\(String(format: "%.1f", rating)) \(stars) (\(place.user_ratings_total ?? 0))")
                        }

                        Text(ratingText)
                            .captionStyle()
                        Spacer()
                    }
                    Text(place.editorial_summary?.overview ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } // end bottom texts
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }//end vstack
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .containerRelativeFrame(.vertical)
        .onTapGesture {
            onTap()
        }
        .task {
            viewModel.fetchStoredPlaces(context: modelContext)
        }
    }
}

#Preview{
    ContentView().environmentObject(GooglePlacesViewModel())
}
