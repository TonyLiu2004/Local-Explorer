//
//  PlacePopup.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/22/25.
//
import SwiftUI
	
struct PlacePopup: View {
    let place: PlaceDetails
    let onClose: () -> Void
    @ObservedObject var viewModel: GooglePlacesViewModel
    
    // slide-up animation state
    @State private var offsetY: CGFloat = 300
    @State private var opacity: CGFloat = 0
        
    let options = [
        Option(label: "Overview", value: "overview"),
        Option(label: "Reviews", value: "Reviews"),
    ]
    
    @State private var selectedOption: String?
    @Environment(\.modelContext) private var modelContext
    @State private var storedPlace: StoredPlaceDetails?
    @State var urls: [URL] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            //Top bar, place name and X button
            HStack {
                Text(place.name)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onClose()
                    }
                })
                {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            
            ScrollView{
                VStack (alignment: .leading, spacing : 12){
                    //Photo gallery
                    
                    ScrollView (.horizontal){
                        HStack{
                            ForEach(self.urls, id: \.self) { url in
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
                    
                    HStack {
                        var ratingText: AttributedString {
                            guard let rating = place.rating else { return AttributedString("") }

                            let full = Int(round(rating))

                            let stars =
                                String(repeating: "⭐️", count: full)

                            return AttributedString("\(String(format: "%.1f", rating)) \(stars) (\(place.user_ratings_total ?? 0))")
                        }

                        Text(ratingText)
                            .captionStyle()
                        Spacer()
                    }
                    
                    if let overview = place.editorial_summary?.overview {
                        Text("\(overview)")
                    }
                    
                    HStack{
                        SelectableBoxRow(
                            options: options,
                            selectedOption: $selectedOption
                        )
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if selectedOption == nil {
                                    selectedOption = options.first?.value
                                }
                            }
                        }
                        
                        //Save button
                        Button {
                            if viewModel.storedPlaceDetailsList.contains(where: { $0.id == place.id }) {
                                viewModel.removePlace(place, context: modelContext)
                            } else {
                                viewModel.savePlace(place, context: modelContext)
                            }
                        } label: {
                            Image(systemName: viewModel.storedPlaceDetailsList.contains(where: { $0.id == place.id }) ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .frame(width: 22, height: 26)
                        }
                    }
                    
                    //selected options overview/review
                    VStack (alignment: .leading, spacing : 12) {
                        if selectedOption == "overview" {
                            // Time
                            HStack {
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .padding(.trailing, 12)
                                if let current = place.current_opening_hours {
                                    var status: AttributedString {
                                        var text = AttributedString(current.open_now == true ? "Open" : "Closed")
                                        text.foregroundColor = current.open_now == true ? .green : .red
                                        return text
                                    }
                                    
                                    Text(status)
                                } else{
                                    Text("No Information")
                                }
                                Spacer()
                                if let times = place.current_opening_hours?.weekday_text {
                                    // gets current day and displays the hours
                                    let calendar = Calendar.current
                                    let todayIndex = calendar.component(.weekday, from: Date())
                                    let weekdayTextIndex = (todayIndex + 5) % 7

                                    if times.indices.contains(weekdayTextIndex) {
                                        Text(times[weekdayTextIndex])
                                            .font(.body)
                                    } else {
                                        Text("Hours unavailable")
                                    }
                                }
                            }
                            
                            // location
                            HStack {
                                Image(systemName: "paperplane")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .padding(.trailing, 12)
                                if let address = place.formatted_address {
                                    Text(address)
                                }
                            }
                            
                            // Phone
                            HStack {
                                Image(systemName: "phone")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .padding(.trailing, 12)
                                if let phone = place.formatted_phone_number{
                                    Text(phone)
                                }
                            }
                            
                            // Website
                            HStack {
                                Image(systemName: "globe")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .padding(.trailing, 12)
                                if let website = place.website{
                                    Text(website)
                                }
                            }
                            
                            // Full Time
                            HStack {
                                Text("").padding(.trailing, 28)
                                if let times = place.current_opening_hours?.weekday_text {
                                    Text(times.joined(separator: "\n"))
                                }
                            }
                        } else {
                            if let reviews = place.reviews {
                                ForEach(reviews.indices, id: \.self) { i in
                                    let review = reviews[i]
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(review.author_name)")
                                            .bold()
                                        if let rating = review.rating, let time = review.relative_time_description {
                                            Text("\(String(repeating: "⭐️", count: Int(rating))) · \(time)")
                                            .captionStyle()
                                        }
                                        if let text = review.text {
                                            Text(text)
                                                .font(.system(size: 14))
                                        }
                                        
                                        Divider()
                                    }
                                } //end foreach
                                
                            }//end if reviews section
                        } // end else
                    }//end selected options vstack
                    .padding(.horizontal, 4)
                }//end vstack
            }
        }//end vstack
        .padding(24)
        .frame(maxWidth: 360)
        .frame(height: 620)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 10)
        .task {
            viewModel.fetchStoredPlaces(context: modelContext)
            
            if viewModel.storedPhotoURL[place.place_id] != nil {
                self.urls = viewModel.storedPhotoURL[place.place_id] ?? []
                print("Loaded \(self.urls.count) urls from storage.")
            } else {
                print("places images not in cache, fetch images.")
                viewModel.fetchAllPhotos(place)
            }
        }
        .onChange(of: viewModel.storedPhotoURL) { _ in
            if let cachedUrls = viewModel.storedPhotoURL[place.place_id] {
                self.urls = cachedUrls
                print("URLs updated from storedPhotoURL cache.")
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
