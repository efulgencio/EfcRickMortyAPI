//
//  ListView.swift
//  EfcRickMorty
//
//  Created by efulgencio on 16/4/24.
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
                        
                        HStack {
                            SearchBarView(searchText: $viewModel.searchText,
                                          clearSearch: $viewModel.clearSearchText)
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
                        
                        paginacion
                            .frame(height: 60)
                }
            }
            .navigationTitle("Characters")
            .environmentObject(characterData)
            .onAppear {
                viewModel.getList()
            }
        }
    }
}

extension ListView {
    
    private var header: some View {
        HStack {
            Text("Rick and Morty")
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
    
    private var listado: some View {
        ForEach(viewModel.characters?.data ?? []) { result in
            VStack(spacing: 0) {
                ItemCharacter(item: result)
                    .frame(height: 90)
                    .onTapGesture {
                        characterData.idSelected = result.id
                        showDetailView = true
                    }
                    .onAppear {
                        // Detectar último item para cargar siguiente página
                        if result.id == viewModel.characters?.data.last?.id {
                            viewModel.loadNextPage()
                        }
                    }
            }
            .sheet(isPresented: $showDetailView) {
                DetailView()
            }
        }
    }
    
    private var paginacion: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Pag.:")
                    .frame(width: 50, height: 50)
                    .font(.subheadline)
                    .background(Color.yellow)
                    .foregroundColor(Color.blue)
                    .cornerRadius(8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1...viewModel.numberPagesForNavigate, id: \.self) { numberPage in
                            Button(action: {
                                viewModel.searchText = ""
                                viewModel.getListByPage(page: "\(numberPage)")
                            }) {
                                Text("\(numberPage)")
                                    .frame(width: 24, height: 20)
                                    .padding()
                                    .background(viewModel.numberPage == numberPage ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.blue, radius: 3)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}


#Preview {
    ListView()
}
