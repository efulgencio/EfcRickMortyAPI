//
//  DetailUseMock.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

extension DetailUseCase {
    public static let mock = Self(
        getCharacter: { id in
            let detailRepository: DetailRepository = .mock
            return detailRepository.getCharacter(id)
                    .map { detailDto in
                        return DetailMapper().mapValue(response: detailDto)
                    }
                    .eraseToAnyPublisher()
        }, getLocation: { id in
            let detailRepository: DetailRepository = .mock
            return detailRepository.getLocation(id)
                    .map { listDto in
                        return DetailMapper().mapValue(response: listDto)
                    }
                    .eraseToAnyPublisher()
        }, getEpisode: {
            let detailRepository: DetailRepository = .mock
            return detailRepository.getEpisode()
                    .map { listDto in
                        return DetailMapper().mapValue(response: listDto)
                    }
                    .eraseToAnyPublisher()
        }
    )
}
