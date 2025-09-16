	//
//  LocationRequestView.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import SwiftUI

struct LocationRequestView: View {

    var body: some View {
        Text("location request view")
        Button {
            LocationManager.shared.requestLocation()
        }label:{
            Text("Request Location")
        }
    }
}
#Preview {
    ContentView()
}
