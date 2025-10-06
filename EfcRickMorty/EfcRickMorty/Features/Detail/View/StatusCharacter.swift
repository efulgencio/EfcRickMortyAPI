//
//  StatusCharacter.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

enum StatusCharacter {
    case alive
    case dead
    case unknown
    
    var iconDescription: String? {
        switch self {
        case .alive: return "Alive 🕺"
        case .dead: return "Dead 💀"
        case .unknown: return "?"
        }
    }
}
