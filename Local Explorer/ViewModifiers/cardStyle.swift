//
//  cardStyle.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/9/25.
//
import SwiftUI

struct CardStyle: ViewModifier {
    var backgroundColor: Color = .LightGreen
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

extension View {
    func cardStyle(
        backgroundColor: Color = .LightGreen,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 2
    ) -> some View {
        self.modifier(CardStyle(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius
        ))
    }
}
