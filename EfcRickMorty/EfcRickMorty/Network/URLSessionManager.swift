//
//  URLSessionManager.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine
import OSLog

final class CombineManager {
    
    static let shared = CombineManager()
    private init() {}
    
    #if DEBUG
    private let isLoggingEnabled: Bool = true
    #else
    private let isLoggingEnabled: Bool = false
    #endif

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EfcRickMorty", category: "Networking")

    private func prettyJSONString(from data: Data) -> String? {
        if let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let string = String(data: prettyData, encoding: .utf8) {
            return string
        }
        return String(data: data, encoding: .utf8)
    }

    private func trimmed(_ string: String, limit: Int = 4000) -> String {
        guard string.count > limit else { return string }
        let end = string.index(string.startIndex, offsetBy: limit)
        return String(string[..<end]) + "… [truncated]"
    }

    func getData<T: Decodable>(endpoint: EndPointProtocol, type: T.Type) -> AnyPublisher<T, NetworkError> {

        let request = NSMutableURLRequest(url: NSURL(string: endpoint.urlString)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
        
        request.httpMethod = endpoint.method
        request.allHTTPHeaderFields = endpoint.headers
        
        // Log request details
        if isLoggingEnabled {
            logger.info("➡️ Request: \(endpoint.method, privacy: .public) \(endpoint.urlString, privacy: .public)")
            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                logger.debug("Headers: \(headers, privacy: .public)")
            }
            if let body = request.httpBody {
                let bodyString = prettyJSONString(from: body) ?? "\(body.count) bytes"
                logger.debug("Body:\n\(self.trimmed(bodyString), privacy: .public)")
            }
        }
        
        return  URLSession.shared.dataTaskPublisher(for: request as URLRequest)
            .handleEvents(
                receiveOutput: { [weak self] data, response in
                    guard let self = self, self.isLoggingEnabled else { return }
                    if let http = response as? HTTPURLResponse {
                        self.logger.info("⬅️ Response: \(http.statusCode, privacy: .public) \(http.url?.absoluteString ?? "", privacy: .public)")
                        self.logger.debug("Response headers: \(http.allHeaderFields, privacy: .public)")
                    }
                    if let pretty = self.prettyJSONString(from: data) {
                        self.logger.debug("Response body:\n\(self.trimmed(pretty), privacy: .public)")
                    } else {
                        self.logger.debug("Response body: \(data.count, privacy: .public) bytes")
                    }
                },
                receiveCompletion: { [weak self] completion in
                    guard let self = self, self.isLoggingEnabled else { return }
                    switch completion {
                    case .finished:
                        self.logger.info("✅ Request finished")
                    case .failure(let error):
                        self.logger.error("❌ Request failed before mapping: \(String(describing: error), privacy: .public)")
                    }
                }
            )
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                    throw NetworkErrorCombine.responseError
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { [weak self] error in
                if let self = self, self.isLoggingEnabled {
                    self.logger.error("❌ Pipeline error: \(String(describing: error), privacy: .public)")
                }
                return NetworkError.convert(error)
            }
            .eraseToAnyPublisher()
    }

}

enum NetworkErrorCombine: Error {
    case invalidURL
    case responseError
    case unknown
}

extension NetworkErrorCombine: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}

