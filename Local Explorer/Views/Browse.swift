//
//  BrowseV.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import SwiftUI
import CoreLocation

struct Browse: View {
    let location: CLLocation
    @StateObject var viewModel = GooglePlacesViewModel()
    
    var body: some View {
        VStack {
            Text("Nearby places around (\(location.coordinate.latitude), \(location.coordinate.longitude))")
                .font(.headline)
            List(viewModel.placeDetailsList, id: \.place_id) { placeDetails in
                VStack(alignment: .leading) {
                    Text(placeDetails.name)
                        .bold()
                    Text(placeDetails.formatted_address ?? "No address")
//                    Text(String(describing: placeDetails))
//                        .font(.caption)
//                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchNearbyPlaces(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                radius: 100
            )
        }
    }
}

#Preview {
    ContentView()
}
