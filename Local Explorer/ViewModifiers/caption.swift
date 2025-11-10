//
//  caption.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/9/25.
//

import SwiftUI

struct CaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.vertical, 0)
            .padding(.horizontal, 0)
    }
}

extension View {
    func captionStyle() -> some View {
        self.modifier(CaptionStyle())
    }
}
