//
//  TextExt.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import SwiftUI

extension Text {
    func customStyle() -> some View {
        self.modifier(CustomTextStyle())
    }
}
