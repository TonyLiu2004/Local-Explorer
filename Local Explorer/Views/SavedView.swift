
import SwiftUI
import SwiftData

struct SavedView: View {
//    @StateObject private var viewModel = GooglePlacesViewModel()
//    @ObservedObject var viewModel: GooglePlacesViewModel
    @EnvironmentObject var viewModel: GooglePlacesViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var placeIDInput: String = ""
    @State private var placeNameInput: String = ""
    let locationManager: LocationManager

    @State private var selectedOption: String?
    @State private var selectedViewModel: GooglePlacesViewModel? = nil
    @State private var selectedPlace: PlaceDetails? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                Text("Saved")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                if let location = locationManager.userLocation {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            if (viewModel.storedPlaceDetailsList.isEmpty) {
                                PlaceCard(
                                    place: PlaceDetails.placeholder,
                                    location:location,
                                    onTap: { },
                                    viewModel: viewModel)
                            } else {
                                ForEach(viewModel.storedPlaceDetailsList.reversed(), id: \.place_id) { placeDetail in
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
                }
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
