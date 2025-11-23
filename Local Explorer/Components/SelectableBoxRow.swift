//
//  SelectableBoxRow.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/9/25.
//
import SwiftUI

struct Option: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: String
}

struct SelectableBoxRow: View {
    let options: [Option]
    @Binding var selectedOption: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    SelectableBox(
                        text: option.label,
                        isSelected: selectedOption == option.value
                    ) {
                        selectedOption = option.value
                    }
                }
            }
//            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
