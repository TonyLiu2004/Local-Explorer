
import SwiftUI
import SwiftData
import CoreLocation

struct SavedView: View {
    @EnvironmentObject var viewModel: GooglePlacesViewModel
    @Environment(\.modelContext) private var modelContext
//    @State private var placeIDInput: String = ""
//    @State private var placeNameInput: String = ""
    let location: CLLocation

//    @State private var selectedOption: String?
//    @State private var selectedViewModel: GooglePlacesViewModel? = nil
    @State private var selectedPlace: PlaceDetails? = nil
    
    @State private var query = ""
    @State private var showHistory = false
    @FocusState private var searchFocused: Bool
    
    var filteredPlaces: [PlaceDetails] {
            guard !viewModel.storedPlaceDetailsList.isEmpty else { return [] }
            guard !query.isEmpty else {
                return viewModel.storedPlaceDetailsList.reversed()
            }
            
            let filtered = viewModel.storedPlaceDetailsList.filter { placeDetail in
                return placeDetail.name
                    .lowercased()
                    .contains(query.lowercased())
            }
            return filtered.reversed()
        }
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                Text("Saved")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                SearchBar(
                    query: $query,
                    searchFocused: $searchFocused,
                    onFocus: { },
                    onSubmit: { print("submitted search for: \(query)")},
                    isBackgroundEnabled: false,
                )
                .padding(.bottom, 12)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        if (filteredPlaces.isEmpty) {
                            PlaceCard(
                                place: PlaceDetails.placeholder,
                                location:location,
                                onTap: { },
                                viewModel: viewModel)
                        } else {
                            ForEach(filteredPlaces, id: \.place_id) { placeDetail in
                                PlaceCard(
                                    place: placeDetail,
                                    location: location,
                                    onTap: {
                                        selectedPlace = placeDetail
                                    },
                                    viewModel: viewModel)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }//end inner scrollview
                
            } //end outer scrollview
            .overlay {
                if let place = selectedPlace {
                    ZStack
                    {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                    }
                    
                    VStack {
                        PlacePopup(
                            place: place,
                            onClose: {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    selectedPlace = nil
                                }
                            },
                            viewModel: viewModel
                        )
                        Spacer()
                    } //end vstack
                    .padding(.top, 16)
                    .transition(.move(edge: .bottom))
                } //end if
            } //end overlay
            .animation(.easeIn(duration: 0.5), value: selectedPlace != nil)
        }
        .padding(.vertical)
        .onAppear() {
            print("fetched in saved view")
            viewModel.fetchStoredPlaces(context: modelContext)
        }
    }
}

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
