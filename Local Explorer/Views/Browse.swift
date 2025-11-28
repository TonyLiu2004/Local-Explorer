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
    @State private var lastLocation: CLLocation?
    @State private var selectedPlace: PlaceDetails? = nil
    
    @State private var history: [String] = ["apple", "banana", "chicken"]
    @State private var query = ""
    @State private var showHistory = false
    
    @FocusState private var searchFocused: Bool
    
    var body: some View {
        VStack {
            ZStack (alignment: .top){
                VStack
                {
                    if !searchFocused {
                        HStack {
                            Spacer()
                            Button {
                                searchFocused = true
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                        }
                    }
                    SearchBar(
                        query: $query,
                        searchFocused: $searchFocused,
                        onFocus: { showHistory = true },
                        onSubmit: submitSearch
                    )
                    .frame(width: searchFocused ? nil : 0, height: searchFocused ? nil : 0)
                    .opacity(searchFocused ? 1 : 0)
                    .allowsHitTesting(searchFocused)
                    
                    SearchHistoryView(
                        history: $history,
                        query: $query,
                        showHistory: $showHistory,
                        searchFocused: $searchFocused
                    )
                }
                .zIndex(100)
                .background { searchFocused ? Color.white : Color.clear }

                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.placeDetailsList, id: \.place_id) { place in
                            PlacePage(
                                place: place,
                                location: location,
                                onTap: {
                                    selectedPlace = place
                                },
                                viewModel: viewModel)
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
            }
        }
        .overlay {
            if let place = selectedPlace {
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
                        viewModel: viewModel
                    )
                    Spacer()
                } //end vstack
                .padding(.top, 16)
                .transition(.move(edge: .bottom))
            } //end if
        } //end overlay
        .animation(.easeIn(duration: 0.5), value: selectedPlace != nil)
        .contentShape(Rectangle())
        .onTapGesture {
            searchFocused = false
            showHistory = false
        }
        .onAppear {
            lastLocation = location
            viewModel.fetchNearbyPlaces(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                keyword: query
            )
        }
//        .onChange(of: query) {
//            viewModel.fetchNearbyPlaces(
//                lat: location.coordinate.latitude,
//                lon: location.coordinate.longitude,
//                keyword: query
//            )
//        }
        .onChange(of: location) {
            if let last = lastLocation {
                let distance = location.distance(from: last) // meters
                if distance > 200 { //about 2.5 streets
                    print("Moved \(distance)m — refetching places")
                    viewModel.fetchNearbyPlaces(
                        lat: location.coordinate.latitude,
                        lon: location.coordinate.longitude,
                        keyword: query
                    )
                    lastLocation = location
                }
            }
        }
        
    }
    
    func submitSearch(){
        print("searching for \(query)")
        viewModel.fetchNearbyPlaces(
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude,
            keyword: query
        )
    }
}


#Preview {
//    Browse(location:CLLocation(latitude: 40.7580, longitude: -73.9855))
    ContentView()
}
