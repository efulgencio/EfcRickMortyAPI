//
//  ListViewModel.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

final class ListViewModel: ObservableObject {
    
    @Published var viewModelState: ViewModelState = .loadingView
    @Published var alertItem: AlertItem?
    @Published var searchText: String = ""
    @Published var clearSearchText: Bool = false
    @Published var debouncedSearchText: String = ""
    
    private var listUseCase: ListUseCase
    private var task: Cancellable?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var characters: ListModel? = nil
    @Published var charactersFiltered: ListModel? = nil
    @Published var numberPage: Int = 0
    @Published var numberPagesForNavigate: Int = 0
    @Published var isLoading: Bool = false
    // Nuevo estado para indicar que la búsqueda no devolvió resultados
    @Published var searchDidNotFindResults: Bool = false
    
    init(listUseCase: ListUseCase = .live) {
        self.listUseCase = listUseCase
        addSubscriberForComponents()
        getList()
    }
    
    private func addSubscriberForComponents() {
        // Combina clearSearchText y searchText con debounce
        Publishers.CombineLatest($searchText, $clearSearchText)
            .removeDuplicates { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == rhs.1
            }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (text, clearSearch) in
                guard let self = self else { return }

                if clearSearch {
                    self.clearSearchText = false // resetear flag
                    self.getList()
                } else {
                    // Solo realizar búsqueda si tiene 3 o más caracteres
                    if text.count >= 3 {
                        self.performSearch(with: text)
                    } else if text.isEmpty {
                        self.getList() // si borra todo, recarga lista completa
                    } else {
                        // opcional: limpiar resultados si < 3 caracteres
                        self.charactersFiltered = self.characters
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(with text: String) {
        if text.isEmpty {
            getList()
        } else {
            isLoading = true
            self.searchDidNotFindResults = false
            
            task = listUseCase.getList(text).sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if case let .failure(error) = completion {
                            // *** NUEVA LÓGICA CLAVE: Manejar el fallo de la API AQUÍ ***
                            
                            // NOTA: Si la API de Rick & Morty devuelve un error 404 (NetworkError)
                            // cuando no hay resultados de búsqueda, usamos eso como señal.
                            // Si tu `listUseCase` mapea el error 404 de "Not Found" a un error específico,
                            // deberías usarlo aquí. Por ahora, asumiremos que si hay un error
                            // Y estamos en una búsqueda activa, es "no encontrado".
                            
                            // Opción 1: Si quieres manejar el fallo de "No encontrado" como un caso de error específico
                            // if error is NetworkError.notFound { ... }
                            
                            // Opción 2 (Simple y funcional en este contexto): Si ocurre un fallo,
                            // asumimos que es "no encontrado" y limpiamos la lista
                            
                            self?.charactersFiltered = ListModel() // Limpiamos la lista
                            self?.searchDidNotFindResults = true
                            self?.viewModelState = .filteredView // MANTENER ESTADO VISIBLE
                            
                            // IMPORTANTE: NO LLAMAMOS a self?.handleCompletion(completion: completion)
                            // para evitar que se muestre el error genérico .errorView.
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    DispatchQueue.main.async {
                        // *** LÓGICA DE VALOR: Comprobar si se obtuvieron resultados. ***
                        if response.data.isEmpty {
                            self?.charactersFiltered = ListModel()
                            self?.searchDidNotFindResults = true
                        } else {
                            self?.charactersFiltered = response
                            self?.searchDidNotFindResults = false
                        }
                        
                        self?.viewModelState = .loadedView
                        self?.isLoading = false
                    }
                }
            )
        }
    }
    
    // Carga inicial o búsqueda
    func getList() {
        self.numberPage = 0
        self.isLoading = true
        self.searchDidNotFindResults = false
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
              searchText.isEmpty, // <-- AÑADIDO: Solo pagina si no hay búsqueda
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

