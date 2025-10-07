//
//  DetailCaseUseLive.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine


extension DetailUseCase {
    
    /// The live implementation of `DetailUseCase` that fetches real data from the API.
    ///
    /// This version uses the `.live` `DetailRepository` to retrieve data from the network
    /// and maps the returned DTOs into `DetailModel` objects using `DetailMapper`.
    public static let live = Self(
        
        /// Fetches detailed information about a specific character by ID.
        ///
        /// - Parameter id: The character ID to retrieve.
        /// - Returns: An `AnyPublisher` emitting a `DetailModel` on success or a `NetworkError` on failure.
        getCharacter: { id in
            let detailRepository: DetailRepository = .live
            return detailRepository.getCharacter(id)
                // Maps the DTO (data transfer object) to the domain model
                .map { listDto in
                    return DetailMapper().mapValue(response: listDto)
                }
                .eraseToAnyPublisher()
        },
        
        /// Fetches detailed information about a specific location by ID.
        ///
        /// - Parameter id: The location identifier.
        /// - Returns: An `AnyPublisher` emitting a `DetailModel` on success or a `NetworkError` on failure.
        getLocation: { id in
            let detailRepository: DetailRepository = .live
            return detailRepository.getLocation(id)
                // Maps the DTO (data transfer object) to the domain model
                .map { listDto in
                    return DetailMapper().mapValue(response: listDto)
                }
                .eraseToAnyPublisher()
        },
        
        /// Fetches detailed information about episodes.
        ///
        /// - Returns: An `AnyPublisher` emitting a `DetailModel` on success or a `NetworkError` on failure.
        getEpisode: {
            let detailRepository: DetailRepository = .live
            return detailRepository.getEpisode()
                // Maps the DTO (data transfer object) to the domain model
                .map { listDto in
                    return DetailMapper().mapValue(response: listDto)
                }
                .eraseToAnyPublisher()
        }
    )
}

