
import SwiftUI
import SwiftData

struct SavedView: View {
//    @StateObject private var viewModel = GooglePlacesViewModel()
//    @ObservedObject var viewModel: GooglePlacesViewModel
    @EnvironmentObject var viewModel: GooglePlacesViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var placeIDInput: String = ""
    @State private var placeNameInput: String = ""
    var body: some View {
        VStack(spacing: 20) {
            List(viewModel.storedPlaceDetailsList, id: \.place_id) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.headline)
                
                    //photo gallery
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
                    //end photo gallery
                    Text("formatted_address: \(place.formatted_address ?? "nil")")
                    Text("formatted_phone_number: \(place.formatted_phone_number ?? "nil")")
                    Text("rating: \(place.rating?.description ?? "nil")")
                    Text("user_ratings_total: \(place.user_ratings_total?.description ?? "nil")")
                    Text("latitude: \(place.geometry.location.lat)")
                    Text("longitude: \(place.geometry.location.lng)")
                    Text("editorial_overview: \(place.editorial_summary?.overview ?? "nil")")
                    
                    let weekdayText = place.current_opening_hours?.weekday_text ?? []
                    ForEach(weekdayText, id: \.self) { dayLine in
                        Text(dayLine)
                    }


                }
            }
        }
        .padding()
        .onAppear() {
            print("fetched in saved view")
            viewModel.fetchStoredPlaces(context: modelContext)
        }
    }
}

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
