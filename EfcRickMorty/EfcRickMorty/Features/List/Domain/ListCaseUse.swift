//
//  ListCaseUse.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

/// A use case that defines the data-fetching operations for retrieving character lists.
///
/// `ListUseCase` provides closures that represent the business logic for fetching character data
/// from a remote API or other data sources. It abstracts the network layer, making it easy to mock
/// or replace for testing purposes.
public struct ListUseCase {
    
    /// A closure that fetches a list of characters based on a search query.
    ///
    /// - Parameter: A `String` representing the search text or query term.
    /// - Returns: An `AnyPublisher` emitting a `ListModel` on success or a `NetworkError` on failure.
    public var getList: (String) -> AnyPublisher<ListModel, NetworkError>
    
    /// A closure that fetches a list of characters corresponding to a specific page number.
    ///
    /// - Parameter: A `String` representing the page number to request.
    /// - Returns: An `AnyPublisher` emitting a `ListModel` on success or a `NetworkError` on failure.
    public var getListByPage: (String) -> AnyPublisher<ListModel, NetworkError>
    
    /// Initializes the use case with the given implementations for fetching lists and paginated data.
    ///
    /// - Parameters:
    ///   - getList: A closure that retrieves a list of characters given a search query.
    ///   - getListByPage: A closure that retrieves characters for a specific page number.
    init(
        getList: @escaping (String) -> AnyPublisher<ListModel, NetworkError>,
        getListByPage: @escaping (String) -> AnyPublisher<ListModel, NetworkError>
    ) {
        self.getList = getList
        self.getListByPage = getListByPage
    }
}

