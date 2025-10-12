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
    let googlePlacesJSON: GooglePlacesResponse?
    let location: CLLocation

    var body: some View {
        VStack {
            Text("Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")

            if let decoded = googlePlacesJSON {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(decoded.results) { place in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name)
                                    .font(.headline)
                                Text(place.place_id)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Divider()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            } else {
                Text("Fetching Google Places data...")
            }
        }
        .padding()
    }	
}

#Preview {
    ContentView()
}

