//
//  DetailRepositoryLive.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

extension DetailRepository {
    public static let live = Self (
        getCharacter: { id in
            return CombineManager.shared.getData(endpoint: EndPoint.character(.one(id)), type: DetailDTO.self)
        },
        getLocation: { id in
            return CombineManager.shared.getData(endpoint: EndPoint.location(.all), type: DetailDTO.self)
        },
        getEpisode: {
            return CombineManager.shared.getData(endpoint: EndPoint.episode(.all), type: DetailDTO.self)
        }
    )
}
