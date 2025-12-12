	//
//  LocationRequestView.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import SwiftUI

struct LocationRequestView: View {

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "safari")
                .resizable()
                .frame(width:200, height:200)
                .padding()
                .foregroundColor(Color.LightGreen)
            
            Text("Would you like to explore places nearby?")
                .foregroundColor(.DarkBlue)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing, .top])
            
            Text("Start sharing your location with us")
                .foregroundColor(.DarkBlue)
                .padding(.top, 8)
                .padding([.leading, .trailing], 100)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                LocationManager.shared.requestLocation()
            }label: {
                Text("Allow Location")
                    .bold()
                    .foregroundColor(.DarkBlue)
                    .frame(width: 270)
                    .padding()
                    .background(Color.LightGreen)
                    .cornerRadius(20)
            }
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.MidGreen)
    }
}

#Preview {
    LocationRequestView()
}
