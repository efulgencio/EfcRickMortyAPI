//
//  ListCaseMock.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

extension ListUseCase {
    
    /// A mock implementation of `ListUseCase` for testing or SwiftUI previews.
    ///
    /// This version uses the `.mock` `ListRepository` to provide predefined data,
    /// allowing tests or previews to run without connecting to a real API.
    ///
    /// It provides concrete implementations for:
    /// - `getList`: Returns a filtered list from mock data.
    /// - `getListByPage`: Returns a paginated list from mock data.
    public static let mock = Self(
        
        /// Retrieves a list of characters from the mock repository, optionally filtered.
        ///
        /// - Parameter forFilter: A string used to filter characters in the mock data.
        /// - Returns: An `AnyPublisher` emitting a `ListModel` built from mock data.
        getList: { forFilter in
            let listRepository: ListRepository = .mock
            return listRepository.getList(forFilter)
                // Maps the DTO (mocked data transfer object) to the domain model
                .map { listDto in
                    return ListMapper().mapValue(response: listDto)
                }
                // Converts to a type-erased publisher
                .eraseToAnyPublisher()
        },
        
        /// Retrieves a paginated list of characters from the mock repository.
        ///
        /// - Parameter numberPage: The page number to fetch from mock data.
        /// - Returns: An `AnyPublisher` emitting a `ListModel` built from mock data.
        getListByPage: { numberPage in
            let listRepository: ListRepository = .mock
            return listRepository.getList(numberPage)
                // Maps the DTO (mocked data transfer object) to the domain model
                .map { listDto in
                    return ListMapper().mapValue(response: listDto)
                }
                // Converts to a type-erased publisher
                .eraseToAnyPublisher()
        }
    )
}

