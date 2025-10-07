//
//  DetailRepository.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

/// A repository responsible for fetching `DetailDTO` objects from a data source.
///
/// `DetailRepository` abstracts the network or data layer, providing closures
/// that return publishers with the results of API calls. This allows dependency
/// injection, easy mocking for tests, and separation from the business logic.
public struct DetailRepository {
    
    /// Closure to fetch detailed information about a specific character by its ID.
    ///
    /// - Parameter: An `Int` representing the character ID.
    /// - Returns: An `AnyPublisher` emitting a `DetailDTO` on success or a `NetworkError` on failure.
    public var getCharacter: (Int) -> AnyPublisher<DetailDTO, NetworkError>
    
    /// Closure to fetch detailed information about a specific location by its identifier.
    ///
    /// - Parameter: A `String` representing the location identifier.
    /// - Returns: An `AnyPublisher` emitting a `DetailDTO` on success or a `NetworkError` on failure.
    public var getLocation: (String) -> AnyPublisher<DetailDTO, NetworkError>
    
    /// Closure to fetch detailed information about episodes.
    ///
    /// - Returns: An `AnyPublisher` emitting a `DetailDTO` on success or a `NetworkError` on failure.
    public var getEpisode: () -> AnyPublisher<DetailDTO, NetworkError>
    
    /// Initializes the `DetailRepository` with the given closures for character, location, and episode data.
    ///
    /// - Parameters:
    ///   - getCharacter: Closure that retrieves detail data for a character by ID.
    ///   - getLocation: Closure that retrieves detail data for a location.
    ///   - getEpisode: Closure that retrieves detail data for episodes.
    public init(
        getCharacter: @escaping (Int) -> AnyPublisher<DetailDTO, NetworkError>,
        getLocation: @escaping (String) -> AnyPublisher<DetailDTO, NetworkError>,
        getEpisode: @escaping () -> AnyPublisher<DetailDTO, NetworkError>
    ) {
        self.getCharacter = getCharacter
        self.getLocation = getLocation
        self.getEpisode = getEpisode
    }
}
