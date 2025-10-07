//
//  DetailMapper.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

/// A mapper class responsible for converting `DetailDTO` objects into `DetailModel` domain models.
///
/// `DetailMapper` inherits from the generic `Mapper` class and provides
/// a concrete implementation for mapping API DTOs to the app's domain model.
/// This ensures that the network layer is decoupled from the UI and business logic.
public class DetailMapper: Mapper<DetailDTO, DetailModel> {
    
    /// Maps a `DetailDTO` object received from the network into a `DetailModel` object used by the app.
    ///
    /// - Parameter response: The `DetailDTO` object returned by the API.
    /// - Returns: A fully populated `DetailModel` object.
    public override func mapValue(response: DetailDTO) -> DetailModel {
        let detailFormatted = DetailModel()
        // Populate the domain model from the DTO
        detailFormatted.fromDto(dto: response)
        return detailFormatted
    }
}
