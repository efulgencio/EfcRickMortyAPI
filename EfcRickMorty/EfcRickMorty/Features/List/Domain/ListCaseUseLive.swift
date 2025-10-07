//
//  ListCaseLive.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

extension ListUseCase {
    
    /// The live implementation of `ListUseCase` that connects to the real API.
    ///
    /// This version uses the `.live` `ListRepository` to fetch remote data and
    /// maps network DTOs into domain models using `ListMapper`.
    ///
    /// It provides concrete implementations for:
    /// - `getList`: Fetching character lists with optional filtering.
    /// - `getListByPage`: Fetching paginated character lists.
    public static let live = Self(
        
        /// Retrieves a list of characters that optionally match a given filter string.
        ///
        /// - Parameter forFilter: A string used to filter characters by name or other criteria.
        /// - Returns: An `AnyPublisher` that emits a `ListModel` on success or a `NetworkError` on failure.
        getList: { forFilter in
            let listRepository: ListRepository = .live
            return listRepository.getList(forFilter)
                // Maps the DTO (data transfer object) to the domain model
                .map { listDto in
                    return ListMapper().mapValue(response: listDto)
                }
                // Converts to a type-erased publisher
                .eraseToAnyPublisher()
        },
        
        /// Retrieves a list of characters corresponding to a specific page number.
        ///
        /// - Parameter numberPage: The page number to fetch from the API.
        /// - Returns: An `AnyPublisher` that emits a `ListModel` on success or a `NetworkError` on failure.
        getListByPage: { numberPage in
            let listRepository: ListRepository = .live
            return listRepository.getListByPage(numberPage)
                // Maps the DTO (data transfer object) to the domain model
                .map { listDto in
                    return ListMapper().mapValue(response: listDto)
                }
                // Converts to a type-erased publisher
                .eraseToAnyPublisher()
        }
    )
}

