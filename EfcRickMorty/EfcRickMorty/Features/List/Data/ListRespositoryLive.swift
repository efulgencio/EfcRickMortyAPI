//
//  ListRespositoryLive.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

extension ListRepository {
    
    /// The live implementation of `ListRepository` that fetches real data from the API.
    ///
    /// This implementation uses `CombineManager` to perform network requests to the
    /// Rick & Morty API endpoints, retrieving `ListDTO` objects. It handles both
    /// filtered queries and paginated requests.
    public static let live = Self(
        
        /// Retrieves a list of characters from the API, optionally filtered by a search string.
        ///
        /// - Parameter forFilter: The search query to filter characters by name or other criteria.
        /// - Returns: An `AnyPublisher` emitting a `ListDTO` on success or a `NetworkError` on failure.
        getList: { forFilter in
            if forFilter.isEmpty {
                // Fetch all characters if no filter is provided
                return CombineManager.shared.getData(endpoint: EndPoint.character(.all), type: ListDTO.self)
            } else {
                // Fetch filtered characters
                return CombineManager.shared.getData(endpoint: EndPoint.character(.filter(forFilter)), type: ListDTO.self)
            }
        },
        
        /// Retrieves a list of characters for a specific page from the API.
        ///
        /// - Parameter numberPage: The page number to fetch.
        /// - Returns: An `AnyPublisher` emitting a `ListDTO` on success or a `NetworkError` on failure.
        getListByPage: { numberPage in
            return CombineManager.shared.getData(endpoint: EndPoint.character(.page(numberPage)), type: ListDTO.self)
        }
    )
}
