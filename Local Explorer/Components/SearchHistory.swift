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
    var onSubmit: () -> Void
    var searchFocused: FocusState<Bool>.Binding
    var body: some View {
        if showHistory && !history.isEmpty && searchFocused.wrappedValue {
            VStack(spacing: 0) {
                //Divider()
                ForEach(history, id: \.self) { item in
                    Button {
                        query = item
                        showHistory = false
                        searchFocused.wrappedValue = false
                        onSubmit()
                        //submit
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                                .padding(.leading, 12)
                                .padding(.trailing, 16)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                            
                            Text(item)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.leading, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    
                    // Divider()
                }
            }
            .background(Color.clear)
            .padding(.horizontal, 6)
        }
    }
}

#Preview{
    ContentView().environmentObject(GooglePlacesViewModel())
}
