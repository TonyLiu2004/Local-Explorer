
import SwiftUI
import SwiftData

struct SavedView: View {
    @StateObject private var viewModel = GooglePlacesViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var placeIDInput: String = ""
    @State private var placeNameInput: String = ""
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                           Text("Add a Sample Place")
                               .font(.headline)
                           
                           TextField("Place ID", text: $placeIDInput)
                               .textFieldStyle(.roundedBorder)
                           
                           TextField("Place Name", text: $placeNameInput)
                               .textFieldStyle(.roundedBorder)
                       }
                       .padding(.horizontal)
            Button("Add Sample Place") {
                addSamplePlace()
            }
            
            Button("Fetch Stored Places") {
                fetchStoredPlaces()
            }
            
            List(viewModel.placeDetailsList, id: \.place_id) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.headline)
                    if let rating = place.rating {
                        Text("Rating: \(rating)")
                    }
                    if let address = place.formatted_address {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
    }
    
    private func addSamplePlace() {
            // Create a sample PlaceDetails object
            let samplePlace = PlaceDetails(
                place_id: placeIDInput,
                name: placeNameInput,
                formatted_address: "123 Main St",
                international_phone_number: nil,
                formatted_phone_number: nil,
                website: nil,
                price_level: nil,
                rating: 4.7,
                user_ratings_total: 100,
                types: nil,
                geometry: Geometry(location: Location(lat: 40.7128, lng: -74.0060), viewport: nil),
                photos: nil,
                opening_hours: nil,
                current_opening_hours: nil,
                reviews: nil,
                business_status: nil,
                vicinity: nil,
                editorial_summary: EditorialSummary(language: "en", overview: "A nice place to visit."),
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
            
            viewModel.savePlaces([samplePlace], context: modelContext)
            
            // Also update the view model list for immediate UI feedback
            viewModel.placeDetailsList.append(samplePlace)
        }
    
    private func fetchStoredPlaces() {
        let stored = viewModel.fetchStoredPlaces(context: modelContext)
        for place in stored {
            print(place.name)
        }
        print("=======")
    }
}

#Preview {
    SavedView()
        .modelContainer(for: StoredPlaceDetails.self)
}
