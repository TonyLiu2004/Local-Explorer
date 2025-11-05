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
    let locationName: String
    @StateObject var allViewModel = GooglePlacesViewModel()
    @StateObject var recommendedViewModel = GooglePlacesViewModel()
    @StateObject var cafesViewModel = GooglePlacesViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed top bar
            VStack(alignment: .leading) {
//                Text("Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "location")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(
                            Circle()
                                .fill(Color.green.opacity(0.3))
                        )
                    Text("Current Location: ")
                        .bold()
                        .font(.caption)
                    + Text(locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(Divider(), alignment: .bottom)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Main title
                    Text("Discover Nearby")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 16) // adds space from top safe area
                    
                    // All Locations
                    HorizontalPlacesList(viewModel: allViewModel, location: location)
                    
                    // Recommended
                    Text("Recommended for you")
                        .font(.headline)
                        .padding(.horizontal)
                    HorizontalPlacesList(viewModel: recommendedViewModel, location: location, type: "restaurant")
                    
                    // Cafes
                    Text("Cafes")
                        .font(.headline)
                        .padding(.horizontal)
                    HorizontalPlacesList(viewModel: cafesViewModel, location: location, type: "cafe")
                } //end Vstack
                .padding(.bottom, 32)
            } //end ScrollView
        } //end Vstack
    }// end body
}

struct HorizontalPlacesList: View {
    @ObservedObject var viewModel: GooglePlacesViewModel
    let location: CLLocation
    var type: String? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                if viewModel.places.isEmpty {
                    PlaceCard(place: .placeholder, viewModel: viewModel)
                } else {
                    ForEach(viewModel.places) { place in
                        PlaceCard(place: place, viewModel: viewModel)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .onAppear {
            viewModel.fetchNearbyPlaces(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                type: type
            )
        }
    }
}

#Preview {
    ContentView()
}

