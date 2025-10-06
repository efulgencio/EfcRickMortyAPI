//
//  info.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

public struct Info: Decodable, Hashable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
