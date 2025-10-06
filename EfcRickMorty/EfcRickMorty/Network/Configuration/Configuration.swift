//
//  Configuration.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

public class ConfigurationNet {
    public static let shared = ConfigurationNet()
    public var data: Config = Config(baseUrl: "https://rickandmortyapi.com/api/")

    
    private init() {}
}
