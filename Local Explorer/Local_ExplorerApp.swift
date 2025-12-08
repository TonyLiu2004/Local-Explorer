//
//  Local_ExplorerApp.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import SwiftUI
import SwiftData

@main
struct Local_ExplorerApp: App {
    @StateObject var viewModel = GooglePlacesViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .modelContainer(for: StoredPlaceDetails.self)
    }
}
