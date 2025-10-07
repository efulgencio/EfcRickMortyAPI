//
//  DetailUseMock.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

extension DetailUseCase {
    
    /// A mock implementation of `DetailUseCase` for testing or SwiftUI previews.
    ///
    /// This version uses the `.mock` `DetailRepository` to provide predefined data,
    /// allowing tests or previews to run without connecting to a real API.
    public static let mock = Self(
        
        /// Fetches detailed information about a specific character by ID from mock data.
        ///
        /// - Parameter id: The character ID to retrieve.
        /// - Returns: An `AnyPublisher` emitting a `DetailModel` built from mock data.
        getCharacter: { id in
            let detailRepository: DetailRepository = .mock
            return detailRepository.getCharacter(id)
                // Maps the DTO (mocked data transfer object) to the domain model
                .map { detailDto in
                    return DetailMapper().mapValue(response: detailDto)
                }
                .eraseToAnyPublisher()
        },
        
        /// Fetches detailed information about a specific location by ID from mock data.
        ///
        /// - Parameter id: The location identifier.
        /// - Returns: An `AnyPublisher` emitting a `DetailModel` built from mock data.
        getLocation: { id in
            let detailRepository: DetailRepository = .mock
            return detailRepository.getLocation(id)
                // Maps the DTO (mocked data transfer object) to the domain model
                .map { listDto in
                    return DetailMapper().mapValue(response: listDto)
                }
                .eraseToAnyPublisher()
        },
        
        /// Fetches detailed information about episodes from mock data.
        ///
        /// - Returns: An `AnyPublisher` emitting a `DetailModel` built from mock data.
        getEpisode: {
            let detailRepository: DetailRepository = .mock
            return detailRepository.getEpisode()
                // Maps the DTO (mocked data transfer object) to the domain model
                .map { listDto in
                    return DetailMapper().mapValue(response: listDto)
                }
                .eraseToAnyPublisher()
        }
    )
}
