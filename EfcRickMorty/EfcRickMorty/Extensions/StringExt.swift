import Foundation

//
//  StringExt.swift
//  EfcRickMorty
//
//  Created by efulgencio on 7/10/25.
//

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

