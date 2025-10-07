//
//  DetailRepositoryMock.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine


extension DetailRepository {
    
    /// A mock implementation of `DetailRepository` for testing or SwiftUI previews.
    ///
    /// This version uses predefined JSON data (`jsonDetailDTO`) to return `DetailDTO` objects,
    /// allowing tests or previews to run without connecting to a real API.
    public static let mock = Self(
        
        /// Fetches mock detailed information about a specific character by ID.
        ///
        /// - Parameter id: The character ID to retrieve.
        /// - Returns: An `AnyPublisher` emitting a `DetailDTO` built from mock data.
        getCharacter: { id in
            let jsonAssets = try! JSONDecoder().decode(DetailDTO.self, from: jsonDetailDTO)
            return Just(jsonAssets)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        },
        
        /// Fetches mock detailed information about a specific location by ID.
        ///
        /// - Parameter id: The location identifier.
        /// - Returns: An `AnyPublisher` emitting a `DetailDTO` built from mock data.
        getLocation: { id in
            let jsonHistoriesMock = try! JSONDecoder().decode(DetailDTO.self, from: jsonDetailDTO)
            return Just(jsonHistoriesMock)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        },
        
        /// Fetches mock detailed information about episodes.
        ///
        /// - Returns: An `AnyPublisher` emitting a `DetailDTO` built from mock data.
        getEpisode: {
            let jsonMarketsMock = try! JSONDecoder().decode(DetailDTO.self, from: jsonDetailDTO)
            return Just(jsonMarketsMock)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
    )
}

