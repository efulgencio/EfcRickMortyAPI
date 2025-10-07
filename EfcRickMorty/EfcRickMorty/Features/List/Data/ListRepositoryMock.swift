//
//  ListRepositoryMock.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine


extension ListRepository {
    
    /// A mock implementation of `ListRepository` for testing or SwiftUI previews.
    ///
    /// This version provides predefined data from local JSON assets, avoiding real network calls.
    /// It allows tests and previews to run deterministically and reliably.
    public static let mock = Self(
        
        /// Retrieves a list of characters from mock data, optionally filtered.
        ///
        /// - Parameter forFilter: The search query (ignored in mock, returns the same data).
        /// - Returns: An `AnyPublisher` emitting a `ListDTO` built from mock JSON data.
        getList: { forFilter in
            // Decode mock JSON data
            let jsonAssetsMock = try! JSONDecoder().decode(ListDTO.self, from: jsonListDTO)
            // Return the data as a Combine publisher
            return Just(jsonAssetsMock)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        },
        
        /// Retrieves a paginated list of characters from mock data.
        ///
        /// - Parameter numberPage: The page number (ignored in mock, returns the same data).
        /// - Returns: An `AnyPublisher` emitting a `ListDTO` built from mock JSON data.
        getListByPage: { numberPage in
            // Decode mock JSON data
            let jsonAssetsMock = try! JSONDecoder().decode(ListDTO.self, from: jsonListDTO)
            // Return the data as a Combine publisher
            return Just(jsonAssetsMock)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
    )
}


