//
//  CachedAsyncImage.swift
//  EfcRickMorty
//
//  Created by Assistant on 03/10/25.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    let placeholder: Image

    @State private var uiImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
            }
        }
        .task(id: url) {
            guard !isLoading, let url else { return }
            isLoading = true
            defer { isLoading = false }

            do {
                let image = try await ImageCache.shared.image(for: url)
                if Task.isCancelled { return }
                uiImage = image
            } catch {
                // Si falla, mantenemos el placeholder
            }
        }
    }
}
