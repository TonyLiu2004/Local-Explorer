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
                    let urls = place.photos?
                    .compactMap { viewModel.photosURL[$0.photo_reference] } ?? []
                    
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
                    
                    HStack
                    {
                        var ratingText: AttributedString {
                            guard let rating = place.rating else { return AttributedString("") }

                            let full = Int(round(rating))

                            let stars =
                                String(repeating: "⭐️", count: full)

                            return AttributedString("\(String(format: "%.1f", rating)) \(stars) (\(place.user_ratings_total ?? 0))")
                        }

                        Text(ratingText)
                            .captionStyle()
//                        if let rating = place.rating {
//                            Text("\(String(format: "%.1f", rating)) ⭐️ (\(place.user_ratings_total ?? 0))")
//                                .captionStyle()
//                        }
                        Spacer()
                    }
                    
                    if let overview = place.editorial_summary?.overview {
                        Text("\(overview)")
                    }
                    
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
                    
                    //save button
                    Button(action: {
                        viewModel.savePlace(place, context: modelContext)
                    }) {
                        Text("Save")
                            .font(.system(size: 14))
                            .bold()
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 16)
                    //end save button
                    
                    //selected options overview/review
                    VStack (alignment: .leading, spacing : 12) {
                        if selectedOption == "overview" {
                            if let current = place.current_opening_hours {
//                                Text(current.open_now == true ? "Open" : "Closed")
                                var status: AttributedString {
                                    var text = AttributedString(current.open_now == true ? "Open" : "Closed")
                                    text.foregroundColor = current.open_now == true ? .green : .red
                                    return text
                                }

                                Text(status)
                            }
                            if let address = place.formatted_address {
                                Text(address)
                            }
                            if let phone = place.formatted_phone_number{
                                Text(phone)
                            }
                            if let times = place.current_opening_hours?.weekday_text {
                                Text("\(times)")
                            }
                        } else {
                            Text("review")
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
                                                .font(.system(size: 16))
                                        }
                                        
                                        Divider()
                                    }
                                } //end foreach
                                
                            }//end if reviews section
                        } // end else
                    }//end selected options vstack
                }//end vstack
            }
        }//end vstack
        .padding(24)
        .frame(maxWidth: 360)
        .frame(height: 620)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 10)
        .task{
            viewModel.fetchAllPhotos(place)
        }
    }
}

#Preview {
    ContentView()
}
