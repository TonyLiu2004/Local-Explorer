//
//  SelectableBoxes.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/9/25.
//
import SwiftUI

struct SelectableBox: View {
    let text: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(isSelected ? .white : .DarkGreen)
            .frame(maxWidth: .infinity)
            .padding(8)
            .cardStyle(backgroundColor: isSelected ? .DarkGreen : .LightGray)
            .onTapGesture {
                onSelect()	
            }
    }
}

#Preview {
    ContentView()
}
