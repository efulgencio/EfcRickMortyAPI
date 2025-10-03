//
//  PagiantionView.swift
//  EfcRickMorty
//
//  Created by efulgencio on 3/10/25.
//

import SwiftUI

struct PaginationView: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onPageSelected: (Int) -> Void
    
    var body: some View {
        HStack {
            // Botón fijo
            Text("Pag.:")
                .frame(width: 50, height: 50)
                .font(.subheadline)
                .background(Color.yellow)
                .foregroundColor(Color.blue)
                .cornerRadius(8)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(1...totalPages, id: \.self) { numberPage in
                            Button(action: {
                                onPageSelected(numberPage)
                                DispatchQueue.main.async {
                                    withAnimation {
                                        proxy.scrollTo(numberPage, anchor: .center)
                                    }
                                }
                            }) {
                                Text("\(numberPage)")
                                    .frame(width: 24, height: 20)
                                    .padding()
                                    .background(currentPage == numberPage ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.blue, radius: 3)
                            }
                            .id(numberPage)
                        }
                    }
                    .padding(.vertical, 5)
                }
                // Scroll automático cuando cambia la página por scroll infinito
                .task(id: currentPage) {
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(currentPage, anchor: .center)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
