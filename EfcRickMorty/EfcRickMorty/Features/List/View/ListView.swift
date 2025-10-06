//
//  ListView.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import SwiftUI

final class CharacterData: ObservableObject {
    @Published var idSelected: Int = 0
}

struct ListView: View {
    
    @StateObject private var viewModel: ListViewModel = ListViewModel()
    @State private var showDetailView: Bool = false
    @StateObject var characterData = CharacterData()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
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
                                // Indicador de carga al final
                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding()
                                }
                            }
                        }
                        .sheet(isPresented: $showDetailView) { // APLICALO AQUÍ
                            DetailView()
                        }
                    
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
    
    private var header: some View {
        HStack {
            Text(NSLocalizedString("rick_morty", comment: ""))
                .font(.headline)
                .fontWeight(.heavy)
        }
        .padding(.horizontal)
    }
    
    private var buttonAction: some View {
        Button(action: {
            viewModel.getList()
        }) {
            Image(systemName: "magnifyingglass.circle")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    private var registrosCargados: some View {
        Text("\(NSLocalizedString("number_registers", comment: "")) \(viewModel.characters?.data.count ?? 0)")
            .infoBadgeStyle()
    }
    
    private var listado: some View {
        // 1. Obtener los datos filtrados
        let characters = viewModel.charactersFiltered?.data ?? []

        // 2. Comprobar si hay resultados
        if viewModel.searchDidNotFindResults {
            // Mostrar "no encontrado" solo si hay un texto de búsqueda y no hay resultados
            return AnyView(
                VStack {
                  // Muestra el mensaje de "no encontrado"
                  ItemCharacter(item: "no encontrado")
                      .frame(height: 90)
                  Spacer() // Para que el mensaje se quede arriba y no en el centro
                }
            )
        } else {
            // Mostrar el listado normal
            return AnyView(
                ForEach(characters) { result in
                    VStack(spacing: 0) {
                        ItemCharacter(item: result)
                            .frame(height: 90)
                            .onTapGesture {
                                characterData.idSelected = result.id
                                showDetailView = true
                            }
                            .onAppear {
                                // Detectar último item para cargar siguiente página
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
