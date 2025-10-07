//
//  DetailRepositoryLive.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

extension DetailRepository {
    
    /// The live implementation of `DetailRepository` that fetches real data from the API.
    ///
    /// This implementation uses `CombineManager` to perform network requests
    /// to the Rick & Morty API endpoints, retrieving `DetailDTO` objects.
    public static let live = Self(
        
        /// Fetches detailed information about a specific character by ID from the API.
        ///
        /// - Parameter id: The character ID to retrieve.
        /// - Returns: An `AnyPublisher` emitting a `DetailDTO` on success or a `NetworkError` on failure.
        getCharacter: { id in
            return CombineManager.shared.getData(endpoint: EndPoint.character(.one(id)), type: DetailDTO.self)
        },
        
        /// Fetches detailed information about locations from the API.
        ///
        /// - Parameter id: The location identifier (currently fetches all locations).
        /// - Returns: An `AnyPublisher` emitting a `DetailDTO` on success or a `NetworkError` on failure.
        getLocation: { id in
            return CombineManager.shared.getData(endpoint: EndPoint.location(.all), type: DetailDTO.self)
        },
        
        /// Fetches detailed information about episodes from the API.
        ///
        /// - Returns: An `AnyPublisher` emitting a `DetailDTO` on success or a `NetworkError` on failure.
        getEpisode: {
            return CombineManager.shared.getData(endpoint: EndPoint.episode(.all), type: DetailDTO.self)
        }
    )
}
