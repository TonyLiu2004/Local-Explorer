//
//  SearchBar.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/27/25.
//
import SwiftUI
import _LocationEssentials

struct SearchBar: View {
    @State private var history: [String] = ["apple", "banana", "chicken"]
    @Binding var query: String
    var searchFocused: FocusState<Bool>.Binding
    var onFocus: () -> Void
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if searchFocused.wrappedValue {
                    Button{
                        searchFocused.wrappedValue = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(12)

                            .foregroundColor(.white)
                    }
                }
                TextField("Search…", text: $query, onEditingChanged: { editing in
                    if editing {
                         onFocus()
                    }
                }, onCommit: {
                        onSubmit()
                        searchFocused.wrappedValue = false
                    }
                )
                .focused(searchFocused)
                .padding(6)
                .foregroundColor(.white)
                
                Button {
                    onSubmit()
                    searchFocused.wrappedValue = false
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(24)
                        .foregroundColor(.white)
                }
            }//end hstack
            .background(
                Color.black.opacity(0.6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black, lineWidth: 1)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 24,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 24
                        )
                    )
            )            .clipShape(
                .rect(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
            )
            
        }//end vstack
        .background(Color.clear)
        .padding([.horizontal, .top], 6)
    }
}

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
