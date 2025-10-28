//
//  BrowseV.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import SwiftUI
import CoreLocation

struct Browse: View {
//    let googlePlacesJSON: GooglePlacesResponse?
    let location: CLLocation

    var body: some View {
        VStack {
            Text("Nearby places around (\(location.coordinate.latitude), \(location.coordinate.longitude))")
                .font(.headline)
//            if let decoded = googlePlacesJSON {
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 10) {
//                        ForEach(decoded.results) { place in
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text(place.name)
//                                    .font(.headline)
//                                Text(place.place_id)
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                Divider()
//                            }
//                            .padding(.horizontal)
//                        }
//                    }
//                }
//            } else {
//                Text("No data yet.")
//            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
