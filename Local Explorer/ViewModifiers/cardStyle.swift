//
//  cardStyle.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/9/25.
//
import SwiftUI

struct CardStyle: ViewModifier {
    var backgroundColor: Color = .white //.LightGreen
    var cornerRadius: CGFloat = 12
    
    var shadowRadius: CGFloat = 2
    var shadowColor: Color = Color.black.opacity(0.15)
    var shadowX: CGFloat = 4
    var shadowY: CGFloat = 6

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(
        backgroundColor: Color = .white, //.LightGreen,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 2,
        shadowColor: Color = Color.black.opacity(0.15),
        shadowX: CGFloat = 4,
        shadowY: CGFloat = 6,
    ) -> some View {
        self.modifier(CardStyle(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowColor: shadowColor,
            shadowX: shadowX,
            shadowY: shadowY
        ))
    }
}
