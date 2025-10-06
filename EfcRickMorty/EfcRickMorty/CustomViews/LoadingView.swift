//
//  LoadingView.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.gray)
                .ignoresSafeArea()
            VStack {
                Text("Cargando ....")
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            .padding()
            .background(.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    LoadingView()
}
