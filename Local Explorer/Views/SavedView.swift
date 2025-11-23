
import SwiftUI
import SwiftData

struct SavedView: View {
    @StateObject private var viewModel = GooglePlacesViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var placeIDInput: String = ""
    @State private var placeNameInput: String = ""
    var body: some View {
        VStack(spacing: 20) {
            
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
                    if let urls = viewModel.storedPhotoURL[place.place_id]{
                        ScrollView (.horizontal){
                            HStack{
                                ForEach(urls, id: \.self) { url in
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 300, height: 200)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 300, height: 200)
                                                .clipped()
                                                .cornerRadius(10)
                                        case .failure:
                                            EmptyView()
                                        @unknown default:
                                            Color.gray
                                                .frame(width: 360, height: 200)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                    } else{
                        Color.gray
                            .frame(width: 360, height: 200)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }

    private func fetchStoredPlaces() {
        let stored = viewModel.fetchStoredPlaces(context: modelContext)
        
        // Convert StoredPlaceDetails -> PlaceDetails (or just store StoredPlaceDetails if your List can handle it)
        let places = stored.map { storedPlace in
            var urls: [URL] = []
            if let photoString = storedPlace.photoURLs, let url = URL(string: photoString) {
                urls = [url]
            }
            viewModel.storedPhotoURL[storedPlace.place_id] = urls
            
            return PlaceDetails(
                place_id: storedPlace.place_id,
                name: storedPlace.name,
                formatted_address: storedPlace.formatted_address,
                international_phone_number: nil,
                formatted_phone_number: nil,
                website: nil,
                price_level: nil,
                rating: storedPlace.rating,
                user_ratings_total: storedPlace.user_ratings_total,
                types: nil,
                geometry: Geometry(location: Location(lat: storedPlace.latitude, lng: storedPlace.longitude), viewport: nil),
                photos: nil,
                opening_hours: nil,
                current_opening_hours: OpeningHours(open_now: nil, periods: nil, weekday_text: storedPlace.weekdayText),
                reviews: nil,
                business_status: nil,
                vicinity: nil,
                editorial_summary: EditorialSummary(language: "en", overview: storedPlace.editorial_overview),
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
        }
        
        viewModel.placeDetailsList = places
        print("Fetched \(places.count) places")
    }
}

#Preview {
    SavedView()
        .modelContainer(for: StoredPlaceDetails.self)
}
