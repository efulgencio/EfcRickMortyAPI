//
//  URLSessionManager.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import Foundation
import Combine
import OSLog

/// Singleton manager responsible for executing network requests using Combine
/// and providing structured logging of requests and responses.
///
/// `CombineManager` centralizes networking logic, error handling, JSON decoding,
/// and detailed logging for debugging purposes.
final class CombineManager {
    
    /// Shared singleton instance of `CombineManager`.
    static let shared = CombineManager()
    
    /// Private initializer to enforce singleton usage.
    private init() {}
    
    /// Flag to enable or disable detailed logging in debug mode.
    #if DEBUG
    private let isLoggingEnabled: Bool = true
    #else
    private let isLoggingEnabled: Bool = false
    #endif

    /// Logger instance for structured logging.
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EfcRickMorty", category: "Networking")
    
    // MARK: - Private helper methods
    
    /// Converts raw `Data` to a pretty-printed JSON string for logging.
    ///
    /// - Parameter data: Raw data received from the network.
    /// - Returns: A formatted JSON string, or raw string if JSON formatting fails.
    private func prettyJSONString(from data: Data) -> String? {
        if let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let string = String(data: prettyData, encoding: .utf8) {
            return string
        }
        return String(data: data, encoding: .utf8)
    }

    /// Trims a string to a given character limit for logging purposes.
    ///
    /// - Parameters:
    ///   - string: The string to trim.
    ///   - limit: Maximum number of characters (default 4000).
    /// - Returns: The trimmed string with a truncation indicator if necessary.
    private func trimmed(_ string: String, limit: Int = 4000) -> String {
        guard string.count > limit else { return string }
        let end = string.index(string.startIndex, offsetBy: limit)
        return String(string[..<end]) + "… [truncated]"
    }
    
    // MARK: - Public methods
    
    /// Executes a network request for a given endpoint and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint conforming to `EndPointProtocol`.
    ///   - type: The type to decode the response into (must conform to `Decodable`).
    /// - Returns: A publisher emitting the decoded object or a `NetworkError`.
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
        
        return URLSession.shared.dataTaskPublisher(for: request as URLRequest)
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

// MARK: - Network Error Types

/// Network errors specific to CombineManager requests.
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
