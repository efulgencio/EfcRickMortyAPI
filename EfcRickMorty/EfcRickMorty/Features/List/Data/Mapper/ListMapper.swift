//
//  ListMapper.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation


public class ListMapper: Mapper<ListDTO, ListModel> {
    public override func mapValue(response: ListDTO) -> ListModel {
        let listFormatted = ListModel()
        listFormatted.fromDto(dto: response)
        return listFormatted
    }
}
