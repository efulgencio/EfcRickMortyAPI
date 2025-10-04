//
//  Styles.swift
//  EfcRickMorty
//
//  Created by efulgencio on 16/4/24.
//

import Foundation
import SwiftUI

struct CustomTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.heavy)
    }
}

struct CustomModifierCardDetailItem: ViewModifier {
    
    let colorBack: Color?
    let heightContent: CGFloat?
    
    init(colorBack: Color = Color.themeItem.header, heightContent: CGFloat = CGFloat(80) ) {
        self.colorBack = colorBack
        self.heightContent = heightContent
    }
    
    func body(content: Content) -> some View {
        content
            .frame(height: heightContent)
            .frame(maxWidth: .infinity)
            .background(colorBack)
            .foregroundColor(.white)
            .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .topRight]))
            .padding(.leading, 0)
            .padding(.trailing, 0)
        
    }
}

struct InfoBadgeStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
            .background(
                Capsule().fill(Color.accentColor.opacity(0.85))
            )
            .accessibilityAddTraits(.isStaticText)
    }
}

extension View {
    func infoBadgeStyle() -> some View {
        self.modifier(InfoBadgeStyle())
    }
}
