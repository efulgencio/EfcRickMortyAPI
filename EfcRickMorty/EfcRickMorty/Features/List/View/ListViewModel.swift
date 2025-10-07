//
//  ListViewModel.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine

/// ViewModel responsible for managing the state and business logic
/// of the character list view in the Rick & Morty app.
///
/// `ListViewModel` handles fetching characters, searching, pagination,
/// and exposes published properties to update the SwiftUI views reactively.
final class ListViewModel: ObservableObject {
    
    // MARK: - Published properties
    
    /// Represents the current state of the view.
    @Published var viewModelState: ViewModelState = .loadingView
    
    /// An optional alert item to show error messages in the UI.
    @Published var alertItem: AlertItem?
    
    /// Current search text input by the user.
    @Published var searchText: String = ""
    
    /// Flag to indicate if the search text should be cleared.
    @Published var clearSearchText: Bool = false
    
    /// Search text after debounce, used internally for optimized searching.
    @Published var debouncedSearchText: String = ""
    
    /// The list use case providing fetching logic.
    private var listUseCase: ListUseCase
    
    /// The current Combine task for network requests.
    private var task: Cancellable?
    
    /// Set of cancellables to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// The full list of characters fetched from the API.
    @Published var characters: ListModel? = nil
    
    /// The filtered list of characters based on search text.
    @Published var charactersFiltered: ListModel? = nil
    
    /// Current page number for pagination.
    @Published var numberPage: Int = 0
    
    /// Total number of pages available for navigation.
    @Published var numberPagesForNavigate: Int = 0
    
    /// Flag indicating if data is currently loading.
    @Published var isLoading: Bool = false
    
    /// Flag indicating if the search returned no results.
    @Published var searchDidNotFindResults: Bool = false
    
    // MARK: - Initialization
    
    /// Initializes the `ListViewModel` with an optional `ListUseCase`.
    ///
    /// - Parameter listUseCase: The use case to fetch list data (default is `.live`).
    init(listUseCase: ListUseCase = .live) {
        self.listUseCase = listUseCase
        addSubscriberForComponents()
        getList()
    }
    
    // MARK: - Private methods
    
    /// Sets up Combine subscribers for search text and clear search events.
    private func addSubscriberForComponents() {
        Publishers.CombineLatest($searchText, $clearSearchText)
            .removeDuplicates { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == rhs.1
            }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (text, clearSearch) in
                guard let self = self else { return }

                if clearSearch {
                    self.clearSearchText = false
                    self.getList()
                } else {
                    if text.count >= 3 {
                        self.performSearch(with: text)
                    } else if text.isEmpty {
                        self.getList()
                    } else {
                        self.charactersFiltered = self.characters
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// Performs a search request based on the given text.
    ///
    /// - Parameter text: The search query string.
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
                            self?.charactersFiltered = ListModel()
                            self?.searchDidNotFindResults = true
                            self?.viewModelState = .filteredView
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    DispatchQueue.main.async {
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
    
    /// Fetches the full list of characters from the API.
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
    
    /// Fetches characters for a specific page.
    ///
    /// - Parameter page: The page number as a string.
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
                        // Replace the list for the first page
                        self?.characters = response
                    } else {
                        // Append new data for subsequent pages
                        self?.characters?.data.append(contentsOf: response.data)
                    }
                    self?.charactersFiltered = self?.characters
                    self?.viewModelState = .loadedView
                    self?.isLoading = false
                }
            }
        )
    }
    
    /// Loads the next page of characters if available.
    func loadNextPage() {
        guard !isLoading,
              searchText.isEmpty,
              numberPage < numberPagesForNavigate else { return }
        let nextPage = numberPage + 1
        getListByPage(page: "\(nextPage)")
    }
    
    /// Handles completion of Combine publishers and updates the state in case of errors.
    ///
    /// - Parameter completion: The completion event from a Combine publisher.
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

