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
    @EnvironmentObject var viewModel: GooglePlacesViewModel
    @State private var lastLocation: CLLocation?
    @State private var selectedPlace: PlaceDetails? = nil
    
    @AppStorage("search_history") private var historyData: Data = Data()
    
    var history: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: historyData)) ?? []
        }
        set {
            historyData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    @State private var query = ""
    @State private var showHistory = false
    @FocusState private var searchFocused: Bool
    
    @State private var currentPlaceId: String?
    @State private var currentRadius: Int = 100
    
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
                                query = ""
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(24)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    VStack(spacing: 0) {
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
                            history: history,
                            query: $query,
                            showHistory: $showHistory,
                            onSubmit: submitSearch,
                            searchFocused: $searchFocused
                        )
                    }
                }
                .zIndex(100)
                if (viewModel.placeDetailsList == []) {
                    Text("No places found")
                }
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.placeDetailsList.enumerated()), id: \.element.place_id) { index, place in
                            if let photos = place.photos, !photos.isEmpty {
                                PlacePage(
                                    place: place,
                                    location: location,
                                    onTap: {
                                        selectedPlace = place
                                    },
                                    viewModel: viewModel
                                )
                                .id(place.place_id)
                                Divider()
                            }
                        }
                    }
                    .scrollTargetLayout() //
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollPosition(id: $currentPlaceId, anchor: .top)
                .onChange(of: currentPlaceId) { _, newId in
                    if let placeId = newId,
                       let index = viewModel.placeDetailsList.firstIndex(where: { $0.place_id == placeId })
                    {
                        print("Current snapped index (derived from ID) is: \(index)")

                        if index == viewModel.placeDetailsList.count - 1 {
                            print("reached end, curr radius: \(currentRadius)")
                            viewModel.fetchNearbyPlaces(
                                lat: location.coordinate.latitude,
                                lon: location.coordinate.longitude,
                                radius: self.currentRadius+20,
                                keyword: query
                            )
                            
                            self.currentRadius+=20
                        }
                    }
                }
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
        
        var newHistory = history

        if !newHistory.contains(query) {
            newHistory.insert(query, at: 0)
        }

        if newHistory.count > 5 {
            newHistory.removeLast()
        }

        historyData = (try? JSONEncoder().encode(newHistory)) ?? Data()
        
        viewModel.fetchNearbyPlaces(
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude,
            keyword: query,
            replace: true
        )
    }
}


#Preview {
//    Browse(location:CLLocation(latitude: 40.7580, longitude: -73.9855))
    ContentView().environmentObject(GooglePlacesViewModel())
}
