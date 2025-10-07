//
//  PagiantionView.swift
//  EfcRickMorty
//
//  Created by efulgencio on 3/10/25.
//

import SwiftUI

struct PageButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 24, height: 20)
            .padding()
            .background(isSelected ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: Color.blue, radius: 3)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

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
                            Button(action: {}) {
                                Text("\(numberPage)")
                            }
                            .buttonStyle(PageButtonStyle(isSelected: currentPage == numberPage))
                            .id(numberPage)
                        }
                    }
                    .padding(.vertical, 5)
                }
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

