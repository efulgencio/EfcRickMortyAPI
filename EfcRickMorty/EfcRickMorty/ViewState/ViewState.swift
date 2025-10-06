//
//  ViewState.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation

enum ViewModelState {
    case loadingView
    case loadedView
    case filteredView
    case errorView(errorMessage:String)
}
