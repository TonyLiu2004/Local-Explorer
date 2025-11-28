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
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                //Start photos
                let urls = place.photos?
                .compactMap { viewModel.photosURL[$0.photo_reference] } ?? []
                
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
                //end Photos
                Spacer()
                //bottom texts vstack
                VStack {
                    Text(place.name)
                        .font(.title3)
                        .bold()
                    Text(place.formatted_address ?? "No address")
                        .font(.title3)
                } // end bottom texts
                .padding()
            }//end vstack
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .containerRelativeFrame(.vertical)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview{
    ContentView()
}
