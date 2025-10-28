//
//  DiscoverView.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//
import SwiftUI
import Foundation
import CoreLocation

struct DiscoverView: View {
//    let googlePlacesJSON: GooglePlacesResponse?
    let location: CLLocation
    @StateObject var viewModel = GooglePlacesViewModel()
    
    var body: some View {
        VStack {
            Text("Discover View")
            Text("Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.places) { place in
                        PlaceCard(place: place, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.top)
        .onAppear {
            viewModel.fetchNearbyPlaces(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
}

#Preview {
    ContentView()
}

