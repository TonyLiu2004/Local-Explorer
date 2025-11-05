//
//  ContentView.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @StateObject var overpassViewModel = OverpassViewModel()
    @StateObject var googlePlacesViewModel = GooglePlacesViewModel()
    
    var body: some View {
        Group {	
            if let location = locationManager.userLocation {
                TabView {
                    DiscoverView(
                        location: location,
                        locationName: locationManager.locationName
                    )
                        .tabItem { Label("Home", systemImage: "house") }

                    Browse(
//                        googlePlacesJSON: googlePlacesViewModel.decoded,
                        location: location
                    )
                        .tabItem { Label("Places", systemImage: "mappin.and.ellipse") }

                    SavedView()
                        .tabItem { Label("Saved", systemImage: "bookmark") }
                }
                .onAppear {
                    googlePlacesViewModel.fetchNearbyPlaces(
                        lat: location.coordinate.latitude,
                        lon: location.coordinate.longitude,
                        radius: 100
                    )
                }
                .onChange(of: location) { oldLocation, newLocation in
                    googlePlacesViewModel.fetchNearbyPlaces(
                        lat: newLocation.coordinate.latitude,
                        lon: newLocation.coordinate.longitude,
                        radius: 100
                    )
                }
            } else {
                LocationRequestView()
            }
        }
    }
}

#Preview {
    ContentView()
}
