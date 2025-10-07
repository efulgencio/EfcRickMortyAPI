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
        case .female: return "woman".localized + " 👩‍⚖️"
        case .male: return "man".localized + " 🤵‍♂️"
        case .unknown: return "?"
        }
    }
}
