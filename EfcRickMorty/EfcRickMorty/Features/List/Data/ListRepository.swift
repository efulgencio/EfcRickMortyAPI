//
//  ListRepository.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

/// A repository responsible for fetching `ListDTO` objects from a data source.
///
/// `ListRepository` abstracts the network or data layer, providing closures
/// that return publishers with the results of API calls. This allows
/// dependency injection and easy mocking for testing.
public struct ListRepository {
    
    /// Closure to fetch a list of characters optionally filtered by a search string.
    ///
    /// - Parameter: A `String` representing the search query or filter.
    /// - Returns: An `AnyPublisher` emitting a `ListDTO` on success or a `NetworkError` on failure.
    public var getList: (String) -> AnyPublisher<ListDTO, NetworkError>
    
    /// Closure to fetch a list of characters corresponding to a specific page number.
    ///
    /// - Parameter: A `String` representing the page number to fetch.
    /// - Returns: An `AnyPublisher` emitting a `ListDTO` on success or a `NetworkError` on failure.
    public var getListByPage: (String) -> AnyPublisher<ListDTO, NetworkError>
    
    /// Initializes a `ListRepository` with the given closures for fetching lists and paginated data.
    ///
    /// - Parameters:
    ///   - getList: Closure that retrieves a list of characters based on a search query.
    ///   - getListByPage: Closure that retrieves characters for a specific page number.
    public init(
        getList: @escaping (String) -> AnyPublisher<ListDTO, NetworkError>,
        getListByPage: @escaping (String) -> AnyPublisher<ListDTO, NetworkError>
    ) {
        self.getList = getList
        self.getListByPage = getListByPage
    }
}
