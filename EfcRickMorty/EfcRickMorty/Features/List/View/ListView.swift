//
//  ListView.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import SwiftUI

/// Observable object to hold the currently selected character ID.
/// This allows communication between views when a character is selected.
final class CharacterData: ObservableObject {
    @Published var idSelected: Int = 0
}

/// Main view that displays a list of Rick & Morty characters.
/// It includes pagination, search functionality, and navigation to the detail view.
struct ListView: View {
    
    /// The main view model that manages the list state and API requests.
    @StateObject private var viewModel: ListViewModel = ListViewModel()
    
    /// Controls the presentation of the detail view sheet.
    @State private var showDetailView: Bool = false
    
    /// Shared data for selected character between views.
    @StateObject var characterData = CharacterData()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Handles different UI states (loading, error, loaded, filtered)
                switch viewModel.viewModelState {
                    
                    case .loadingView:
                        LoadingView()
                    
                    case .errorView(let error):
                        Text(error)
                    
                    case .loadedView, .filteredView:
                        header
                        registrosCargados
                        
                        HStack {
                            SearchBarView(searchText: $viewModel.searchText, clearSearch: $viewModel.clearSearchText)
                            buttonAction
                        }
                        .padding(.horizontal, 10)
                        .background(Color.yellow)
                        
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                listado
                                // Loading indicator shown when fetching more data
                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding()
                                }
                            }
                        }
                        .sheet(isPresented: $showDetailView) {
                            DetailView()
                        }
                    
                        // Pagination control at the bottom of the list
                        PaginationView(currentPage: $viewModel.numberPage, totalPages: viewModel.numberPagesForNavigate) { selectedPage in
                            viewModel.searchText = ""
                            viewModel.getListByPage(page: "\(selectedPage)")
                        }
                        .frame(height: 60)
                }
            }
            .navigationTitle("Characters")
            .environmentObject(characterData)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.getList()
            }
        }
    }
}

extension ListView {
    
    /// Header section showing the localized title of the list.
    private var header: some View {
        HStack {
            Text(NSLocalizedString("rick_morty", comment: ""))
                .font(.headline)
                .fontWeight(.heavy)
        }
        .padding(.horizontal)
    }
    
    /// Button that triggers a new API fetch for the character list.
    private var buttonAction: some View {
        Button(action: {
            viewModel.getList()
        }) {
            Image(systemName: "magnifyingglass.circle")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    /// Displays the total number of characters loaded.
    private var registrosCargados: some View {
        Text("\(NSLocalizedString("number_registers", comment: "")) \(viewModel.characters?.data.count ?? 0)")
            .infoBadgeStyle()
    }
    
    /// Displays the list of characters or a message if no results were found.
    private var listado: some View {
        let characters = viewModel.charactersFiltered?.data ?? []

        if viewModel.searchDidNotFindResults {
            return AnyView(
                VStack {
                    // Translated: “Not found”
                    ItemCharacter(item: "not found")
                        .frame(height: 90)
                    Spacer()
                }
            )
        } else {
            // Display the normal list of characters
            return AnyView(
                ForEach(characters) { result in
                    VStack(spacing: 0) {
                        ItemCharacter(item: result)
                            .frame(height: 90)
                            .onTapGesture {
                                // Set the selected character and show the detail view
                                characterData.idSelected = result.id
                                showDetailView = true
                            }
                            .onAppear {
                                // Loads the next page when the last item appears
                                if result.id == characters.last?.id {
                                    viewModel.loadNextPage()
                                }
                            }
                    }
                }
            )
        }
    }
}

#Preview {
    ListView()
}

