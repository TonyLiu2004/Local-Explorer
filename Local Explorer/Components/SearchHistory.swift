//
//  SearchHistory.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/27/25.
//

import SwiftUI

struct SearchHistoryView: View {
    let history: [String]
    @Binding var query: String
    @Binding var showHistory: Bool
    var searchFocused: FocusState<Bool>.Binding // Use FocusState.Binding for the boolean state

    var body: some View {
        if showHistory && !history.isEmpty && searchFocused.wrappedValue {
            VStack {
                Divider()
                ForEach(history, id: \.self) { item in
                    Button {
                        query = item
                        showHistory = false
                        searchFocused.wrappedValue = false
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                                .padding(.horizontal)
                            Text(item)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                }
            }
            .background(Color(.systemGray6))
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color(.systemGray3), lineWidth: 1)
//            )
        }
    }
}

#Preview{
    ContentView().environmentObject(GooglePlacesViewModel())
}
