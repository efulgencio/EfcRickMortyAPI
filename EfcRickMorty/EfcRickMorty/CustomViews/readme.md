import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    init() {
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

## CustomViews – CachedAsyncImage e ImageCache

Esta sección documenta la caché de imágenes basada en `actor` y la vista reutilizable `CachedAsyncImage` empleada en las vistas personalizadas del proyecto.

### Objetivo
- Evitar descargas repetidas de imágenes.
- Acelerar el rendering en listas y tarjetas.
- Mantener el acceso concurrente seguro mediante `actor`.

### ImageCache (actor, singleton)

El `actor` `ImageCache` utiliza `NSCache` para almacenar `UIImage` en memoria. Antes de descargar, consulta el caché; si no existe, descarga, decodifica y guarda la imagen.

```swift
import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    init() {
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
