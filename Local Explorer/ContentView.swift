//
//  ContentView.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @StateObject var googlePlacesViewModel = GooglePlacesViewModel()
    
    var body: some View {
        Group {
            //Top Bar
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
                    + Text(locationManager.locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(Divider(), alignment: .bottom)
            
            if let location = locationManager.userLocation {
                TabView {
                    DiscoverView(
//                      location: location,
                        locationManager: locationManager
                    )
                        .tabItem { Label("Home", systemImage: "house") }

                    Browse(
                        location: location
                    )
                        .tabItem { Label("Places", systemImage: "mappin.and.ellipse") }

                    SavedView()
                        .tabItem { Label("Saved", systemImage: "bookmark") }
                }
//                .onAppear {
//                    googlePlacesViewModel.fetchNearbyPlaces(
//                        lat: location.coordinate.latitude,
//                        lon: location.coordinate.longitude,
//                        radius: 100
//                    )
//                }
//                .onChange(of: location) { oldLocation, newLocation in
//                    googlePlacesViewModel.fetchNearbyPlaces(
//                        lat: newLocation.coordinate.latitude,
//                        lon: newLocation.coordinate.longitude,
//                        radius: 100
//                    )
//                }
            } else {
                LocationRequestView()
            }
        }
    }
}

#Preview {
    ContentView()
}
