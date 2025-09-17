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
    var body: some View {
        Group {
            if let location = locationManager.userLocation {
                VStack {
                    Text("Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    Text("Hello World")
                    if let json = overpassViewModel.overpassJSON {
                        Text("Restaurants JSON fetched!")
                        Text(json)
                        // Or parse and show nicely
                    } else {
                        Text("Fetching restaurants...")
                    }
                }
                .onAppear {
                    overpassViewModel.fetchRestaurants(
                        lat: location.coordinate.latitude,
                        lon: location.coordinate.longitude)
                }
                .onChange(of: location) { oldLocation, newLocation in
                    // Fetch again whenever location changes
                    overpassViewModel.fetchRestaurants(
                        lat: newLocation.coordinate.latitude,
                        lon: newLocation.coordinate.longitude
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
