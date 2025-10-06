//
//  EndPointProtocol.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

public protocol EndPointProtocol {
    var headers: [String: String] { get }
    var method: String { get }
    var urlString: String { get }
    var parameters: [String: Any] { get }
}
