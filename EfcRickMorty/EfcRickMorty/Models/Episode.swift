//
//  Exchange.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation


public struct Episode: Decodable, Hashable {
    let id: Int
    let name: String
    let air_date: String
    let characters: [String]
    let url: String
    let created: String
}

public struct Episodes: Decodable {
    public var data: [Episode]
    public init() { self.data = [Episode]() }
}
