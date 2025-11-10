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
    @StateObject var allViewModel = GooglePlacesViewModel()
    @StateObject var recommendedViewModel = GooglePlacesViewModel()
    @StateObject var cafesViewModel = GooglePlacesViewModel()
    
    let options = [
        Option(label: "All", value: "all"),
        Option(label: "Restaurants", value: "restaurant"),
        Option(label: "Parks", value: "park"),
        Option(label: "Shopping", value: "store"),
        Option(label: "Cafes", value: "cafe"),
        Option(label: "Museums", value: "museum")
    ]
    
    @State private var selectedOption: String?
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Main title
                    Text("Discover Nearby")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 16) // adds space from top safe area
                    //Selectable Boxes
                    SelectableBoxRow(
                        options: options,
                        selectedOption: $selectedOption
                    )
                    .onAppear {
                        if selectedOption == nil {
                            selectedOption = options.first?.value
                        }
                    }
                    
                    // All Locations
                    HorizontalPlacesList(viewModel: allViewModel, location: location, type: selectedOption)
                    
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
            LazyHStack(spacing: 16) {
                if viewModel.places.isEmpty {
                    PlaceCard(place: PlaceDetails.placeholder, location:location, viewModel: viewModel)
                } else {
//                    ForEach(viewModel.places) { place in
//                        PlaceCard(place: place, viewModel: viewModel)
//                    }
                    ForEach(viewModel.placeDetailsList.filter { $0.photos != nil && !$0.photos!.isEmpty }) { placeDetail in
                        PlaceCard(place: placeDetail, location: location, viewModel: viewModel)
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
        .onChange(of: type) {
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

