//
//  ImageCache.swift
//  EfcRickMorty
//
//  Created by Assistant on 03/10/25.
//

import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    init() {
        // Ajusta estos límites a tus necesidades
        cache.countLimit = 200               // máximo número de imágenes
        cache.totalCostLimit = 50 * 1024 * 1024 // ~50 MB
    }

    enum ImageError: Error {
        case decodingFailed
    }

    func image(for url: URL) async throws -> UIImage {
        let key = url as NSURL

        if let cached = cache.object(forKey: key) {
            return cached
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageError.decodingFailed
        }

        // Estimar coste para NSCache
        let cost: Int
        if let cg = image.cgImage {
            cost = cg.bytesPerRow * cg.height
        } else {
            cost = data.count
        }

        cache.setObject(image, forKey: key, cost: cost)
        return image
    }

    func removeImage(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}
