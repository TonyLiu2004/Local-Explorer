//
//  ContentView.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    var body: some View {
        Group {
            if locationManager.userLocation == nil {
                LocationRequestView()
            } else {
                Text("Hello World")
            }
        }
    }
}

#Preview {
    ContentView()
}
