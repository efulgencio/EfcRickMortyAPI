//
//  jsonEpisode.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

let jsonEpisode = """
{
  "id": 1,
  "name": "Pilot",
  "air_date": "December 2, 2013",
  "episode": "S01E01",
  "characters": [
    "https://rickandmortyapi.com/api/character/1",
    "https://rickandmortyapi.com/api/character/2"
  ],
  "url": "https://rickandmortyapi.com/api/episode/1",
  "created": "2017-11-10T12:56:33.798Z"
}
""".data(using: .utf8)!
