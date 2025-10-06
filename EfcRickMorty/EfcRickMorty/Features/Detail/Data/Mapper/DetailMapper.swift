//
//  DetailMapper.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation


public class DetailMapper: Mapper<DetailDTO, DetailModel> {
    public override func mapValue(response: DetailDTO) -> DetailModel {
        let detailFormatted = DetailModel()
        detailFormatted.fromDto(dto: response)
        return detailFormatted
    }
}

