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

    let options = [
        Option(label: "All", value: "all"),
        Option(label: "Restaurants", value: "restaurant"),
        Option(label: "Parks", value: "park"),
        Option(label: "Shopping", value: "store"),
        Option(label: "Cafes", value: "cafe"),
        Option(label: "Museums", value: "museum")
    ]
    
    @State private var selectedOption: String?
    @State private var selectedViewModel: GooglePlacesViewModel? = nil
    @State private var selectedPlace: PlaceDetails? = nil

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
                    .padding(.horizontal)
                    .onAppear {
                        if selectedOption == nil {
                            selectedOption = options.first?.value
                        }
                    }
                    
                    // All Locations
                    if let location = locationManager.userLocation
                    {
                        HorizontalPlacesList(
                            viewModel: allViewModel,
                            location: location,
                            type: selectedOption,
                            onSelect: { place, vm in
                                selectedPlace = place
                                selectedViewModel = vm
                            }
                        )
                    
                        // Recommended
                        Text("Recommended for you")
                            .font(.headline)
                            .padding(.horizontal)
                        HorizontalPlacesList(
                            viewModel: recommendedViewModel,
                            location: location,
                            type: "restaurant",
                            onSelect: { place, vm in
                                selectedPlace = place
                                selectedViewModel = vm
                            }
                        )
                        
                        // Cafes
                        Text("Cafes")
                            .font(.headline)
                            .padding(.horizontal)
                        HorizontalPlacesList(
                            viewModel: cafesViewModel,
                            location: location,
                            type: "cafe",
                            onSelect: { place, vm in
                                selectedPlace = place
                                selectedViewModel = vm
                            }
                        )
                    }
                } //end Vstack
                .padding(.bottom, 32)
            } //end ScrollView
            .overlay {
                if let place = selectedPlace, let vm = selectedViewModel {
                    ZStack
                    {
                        Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    }
                    
                    VStack {
                        PlacePopup(
                            place: place,
                            onClose: {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    selectedPlace = nil
                                }
                            },
                            viewModel: vm
                        )
                        Spacer()
                    } //end vstack
                    .padding(.top, 16)
                    .transition(.move(edge: .bottom))
                } //end if
            } //end overlay
            .animation(.easeIn(duration: 0.5), value: selectedPlace != nil)
        } //end Vstack
    }// end body
}

struct HorizontalPlacesList: View {
    @ObservedObject var viewModel: GooglePlacesViewModel
    let location: CLLocation
    var type: String? = nil
    @State private var lastLocation: CLLocation?
    var onSelect: (PlaceDetails, GooglePlacesViewModel) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                if (viewModel.placeDetailsList.isEmpty) {
                    PlaceCard(
                        place: PlaceDetails.placeholder,
                        location:location,
                        onTap: { },
                        viewModel: viewModel)
                } else {
                    ForEach(viewModel.placeDetailsList) { placeDetail in
                        PlaceCard(
                            place: placeDetail,
                            location: location,
                            onTap: {
                                onSelect(placeDetail, viewModel)
                            },
                            viewModel: viewModel)
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
            print("type changed, fetching: ")
            viewModel.fetchNearbyPlaces(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                type: type,
                replace: true
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

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
