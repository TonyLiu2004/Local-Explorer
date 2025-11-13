//
//  DiscoverView.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//
import SwiftUI
import CoreLocation

struct DiscoverView: View {
    let locationManager: LocationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject var allViewModel = GooglePlacesViewModel()
    @StateObject var recommendedViewModel = GooglePlacesViewModel()
    @StateObject var cafesViewModel = GooglePlacesViewModel()

    @State private var reply = "qwe"
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
                    if let location = locationManager.userLocation
                    {
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
                    }
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
    @State private var lastLocation: CLLocation?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                if (viewModel.placeDetailsList.isEmpty) {
                    PlaceCard(place: PlaceDetails.placeholder, location:location, viewModel: viewModel)
                } else {
                    ForEach(viewModel.placeDetailsList) { placeDetail in
                        PlaceCard(place: placeDetail, location: location, viewModel: viewModel)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        } //end scrollview
        .onAppear {
            lastLocation = location
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
        .onChange(of: location) {
            if let last = lastLocation {
                let distance = location.distance(from: last) // meters
                if distance > 200 { //about 2.5 streets
                    print("Moved \(distance)m — refetching places")
                    viewModel.fetchNearbyPlaces(
                        lat: location.coordinate.latitude,
                        lon: location.coordinate.longitude,
                        type: type
                    )
                    lastLocation = location
                }
            }
        }
    }
}

class MockLocationManager: LocationManager {
    override init() {
        super.init()
        self.userLocation = CLLocation(latitude: 40.758683, longitude: -73.8331742)
    }
}

#Preview {
    DiscoverView(locationManager: MockLocationManager())
        .modelContainer(for: StoredPlaceDetails.self)
}

