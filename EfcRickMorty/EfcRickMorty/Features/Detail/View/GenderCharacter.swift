//
//  GenderCharacter.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

enum GenderCharacter {
    case female
    case male
    case unknown
    
    var iconDescription: String? {
        switch self {
        case .female: return "Mujer 👩‍⚖️"
        case .male: return "Hombre 🤵‍♂️"
        case .unknown: return "?"
        }
    }
}
