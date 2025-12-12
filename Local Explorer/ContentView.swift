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
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
//            Top Bar
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "location")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(
                            Circle()
                                .fill(Color.green.opacity(0.3))
                        )
                    var attributed: AttributedString {
                        var title = AttributedString("Current Location: ")
                        title.font = .caption.bold()

                        var value = AttributedString(locationManager.locationName)
                        value.font = .caption
                        value.foregroundColor = .secondary

                        return title + value
                    }
                    Text(attributed)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            if let location = locationManager.userLocation {
                TabView {
                    DiscoverView(
                        locationManager: locationManager
                    )
                        .tabItem { Label("Discover", systemImage: "house") }

                    Browse(
                        location: location
                    )
                        .tabItem { Label("Browse", systemImage: "mappin.and.ellipse") }

                    SavedView(
                        location: location
                    )
                        .tabItem { Label("Saved", systemImage: "bookmark") }
                }
            } else {
                LocationRequestView()
            }
        } //end main Vstack
        .task {
            googlePlacesViewModel.fetchStoredPlaces(context: modelContext)
        }
    }
}

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
