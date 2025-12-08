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
                    Button("<"){
                        searchFocused.wrappedValue = false
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
                .foregroundColor(.black)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                
                Button {
                    onSubmit()
                    searchFocused.wrappedValue = false
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView().environmentObject(GooglePlacesViewModel())
}
