//
//  DetailCaseUse.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

/// A use case that defines the data-fetching operations for retrieving detail information.
///
/// `DetailUseCase` provides closures to fetch detailed data about characters, locations,
/// and episodes from the API. This abstraction allows easy mocking, testing, and separation
/// of the network layer from business logic.
public struct DetailUseCase {
    
    /// Closure to fetch detailed information about a specific character by its ID.
    ///
    /// - Parameter: An `Int` representing the character ID.
    /// - Returns: An `AnyPublisher` emitting a `DetailModel` on success or a `NetworkError` on failure.
    public var getCharacter: (Int) -> AnyPublisher<DetailModel, NetworkError>
    
    /// Closure to fetch detailed information about a specific location by its name or identifier.
    ///
    /// - Parameter: A `String` representing the location identifier.
    /// - Returns: An `AnyPublisher` emitting a `DetailModel` on success or a `NetworkError` on failure.
    public var getLocation: (String) -> AnyPublisher<DetailModel, NetworkError>
    
    /// Closure to fetch detailed information about episodes.
    ///
    /// - Returns: An `AnyPublisher` emitting a `DetailModel` on success or a `NetworkError` on failure.
    public var getEpisode: () -> AnyPublisher<DetailModel, NetworkError>
    
    /// Initializes the `DetailUseCase` with the given closures for character, location, and episode data.
    ///
    /// - Parameters:
    ///   - getCharacter: Closure that retrieves detail data for a character by ID.
    ///   - getLocation: Closure that retrieves detail data for a location.
    ///   - getEpisode: Closure that retrieves detail data for episodes.
    init(
        getCharacter: @escaping (Int) -> AnyPublisher<DetailModel, NetworkError>,
        getLocation: @escaping (String) -> AnyPublisher<DetailModel, NetworkError>,
        getEpisode: @escaping () -> AnyPublisher<DetailModel, NetworkError>
    ) {
        self.getCharacter = getCharacter
        self.getLocation = getLocation
        self.getEpisode = getEpisode
    }
}
