//
//  Local_ExplorerTests.swift
//  Local ExplorerTests
//
//  Created by Tony Liu on 11/24/25.
//

import Testing
import SwiftData
@testable import Local_Explorer

struct Local_ExplorerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test
        func testSavePlaceStoresInContext() async throws {
            let config = ModelConfiguration(
                for: StoredPlaceDetails.self,
                isStoredInMemoryOnly: true
            )

            let container = try ModelContainer(
                for: StoredPlaceDetails.self,
                configurations: config
            )

            let context = ModelContext(container)
            
            let vm = GooglePlacesViewModel()

            // Create sample PlaceDetails
            let place = PlaceDetails(
                place_id: "test123",
                name: "Test Place",
                formatted_address: "123 Main St",
                international_phone_number: nil,
                formatted_phone_number: "555-1234",
                website: nil,
                price_level: nil,
                rating: 4.5,
                user_ratings_total: 10,
                types: nil,
                geometry: Geometry(location: Location(lat: 0, lng: 0), viewport: nil),
                photos: nil,
                opening_hours: nil,
                current_opening_hours: nil,
                reviews: nil,
                business_status: nil,
                vicinity: nil,
                editorial_summary: nil,
                url: nil,
                delivery: nil,
                dine_in: nil,
                takeout: nil,
                serves_breakfast: nil,
                serves_brunch: nil,
                serves_lunch: nil,
                serves_dinner: nil,
                serves_beer: nil,
                serves_wine: nil,
                serves_vegetarian_food: nil,
                reservable: nil,
                wheelchair_accessible_entrance: nil
            )

            // Call savePlace
            vm.savePlace(place, context: context)

            // Fetch and assert
            let stored = vm.getStoredPlace(placeID: "test123", context: context)

            #expect(stored != nil)
            #expect(stored?.name == "Test Place")
            #expect(stored?.formatted_address == "123 Main St")
        }

}
