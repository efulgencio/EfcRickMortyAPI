//
//  ListMapper.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//


import Foundation

/// A mapper class responsible for converting `ListDTO` objects into `ListModel` domain models.
///
/// `ListMapper` inherits from the generic `Mapper` class and provides
/// a concrete implementation for mapping API DTOs to the app's domain model.
/// This ensures that the network layer is decoupled from the UI and business logic.
public class ListMapper: Mapper<ListDTO, ListModel> {
    
    /// Maps a `ListDTO` object received from the network into a `ListModel` object used by the app.
    ///
    /// - Parameter response: The `ListDTO` object returned by the API.
    /// - Returns: A fully populated `ListModel` object.
    public override func mapValue(response: ListDTO) -> ListModel {
        let listFormatted = ListModel()
        // Populate the domain model from the DTO
        listFormatted.fromDto(dto: response)
        return listFormatted
    }
}

