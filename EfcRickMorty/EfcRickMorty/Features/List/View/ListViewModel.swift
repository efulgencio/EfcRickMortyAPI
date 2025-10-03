//
//  ListViewModel.swift
//  EfcRickMorty
//
//  Created by efulgencio on 16/4/24.
//

import Foundation
import Combine

final class ListViewModel: ObservableObject {
    
    @Published var viewModelState: ViewModelState = .loadingView
    @Published var alertItem: AlertItem?
    @Published var searchText: String = ""
    @Published var clearSearchText: Bool = false
    
    private var listUseCase: ListUseCase
    private var task: Cancellable?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var characters: ListModel? = nil
    @Published var charactersFiltered: ListModel? = nil
    @Published var numberPage: Int = 0
    @Published var numberPagesForNavigate: Int = 0
    @Published var isLoading: Bool = false
    
    init(listUseCase: ListUseCase = .live) {
        self.listUseCase = listUseCase
        addSubscriberForComponents()
        getList()
    }
    
    private func addSubscriberForComponents() {
        $clearSearchText
            .sink { [weak self] (clearSearch) in
                if clearSearch {
                    self?.getList()
                }
            }
            .store(in: &cancellables)
    }
    
    // Carga inicial o búsqueda
    func getList() {
        self.numberPage = 0
        self.isLoading = true
        task = listUseCase.getList(searchText).sink(
            receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion: completion)
            },
            receiveValue: { [weak self] response in
                DispatchQueue.main.async {
                    self?.characters = response
                    self?.charactersFiltered = response
                    self?.numberPagesForNavigate = response.numberPages
                    self?.numberPage = 1
                    self?.viewModelState = .loadedView
                    self?.isLoading = false
                }
            }
        )
    }
    
    // Carga de página específica
    func getListByPage(page: String) {
        guard let pageInt = Int(page) else { return }
        self.numberPage = pageInt
        self.isLoading = true
        
        task = listUseCase.getListByPage(page).sink(
            receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion: completion)
            },
            receiveValue: { [weak self] response in
                DispatchQueue.main.async {
                    if pageInt == 1 {
                        // Reemplaza lista
                        self?.characters = response
                    } else {
                        // Añadir al listado existente
                        self?.characters?.data.append(contentsOf: response.data)
                    }
                    self?.charactersFiltered = self?.characters
                    self?.viewModelState = .loadedView
                    self?.isLoading = false
                }
            }
        )
    }
    
    // Carga siguiente página automática
    func loadNextPage() {
        guard !isLoading,
              numberPage < numberPagesForNavigate else { return }
        let nextPage = numberPage + 1
        getListByPage(page: "\(nextPage)")
    }
    
    private func handleCompletion(completion: Subscribers.Completion<NetworkError>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            DispatchQueue.main.async {
                self.alertItem = AlertContext.errorAPI
                self.isLoading = false
            }
            print(error.localizedDescription)
        }
    }
}

