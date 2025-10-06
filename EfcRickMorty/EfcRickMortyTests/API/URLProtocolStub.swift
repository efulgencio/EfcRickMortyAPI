import Foundation

/// `URLProtocolStub` is a custom `URLProtocol` for intercepting network requests
/// in unit tests. It allows simulating HTTP responses with data, errors, or delays.
final class URLProtocolStub: URLProtocol {
    
    /// Data to return in the simulated response.
    static var responseData: Data?
    
    /// HTTP status code of the response (defaults to 200).
    static var statusCode: Int = 200
    
    /// HTTP headers for the simulated response.
    static var headers: [String: String] = [:]
    
    /// Counter for intercepted requests (useful for validation in tests).
    static var requestCount: Int = 0
    
    /// Error to return instead of a successful response (simulates network failures).
    static var error: Error?
    
    /// Artificial delay before responding (simulates network latency).
    static var responseDelay: TimeInterval = 0

    // MARK: - URLProtocol Overrides
    
    /// Determines if this protocol can handle a given request.
    ///
    /// - Parameter request: The `URLRequest` to be evaluated.
    /// - Returns: `true` to indicate that all requests are intercepted.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    /// Returns the "canonical" request, i.e., the standard version of the request.
    ///
    /// - Parameter request: The original `URLRequest`.
    /// - Returns: The same request without modifications.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    /// Starts loading the intercepted request.
    /// Simulates the response by returning data, headers, and HTTP code, or an error if configured.
    ///
    /// - Behavior:
    ///   1. Validates the request's URL.
    ///   2. Increments the request counter.
    ///   3. If an error was configured, it's returned to the client.
    ///   4. Otherwise, it constructs an `HTTPURLResponse` with `statusCode` and `headers`.
    ///   5. Returns the data (`responseData` or empty).
    ///   6. Marks the loading as finished.
    ///   7. If `responseDelay` is set, it waits for that duration before responding.
    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        URLProtocolStub.requestCount += 1

        let respond: () -> Void = { [weak self] in
            guard let self = self else { return }
            if let error = URLProtocolStub.error {
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }
            let response = HTTPURLResponse(url: url,
                                           statusCode: URLProtocolStub.statusCode,
                                           httpVersion: nil,
                                           headerFields: URLProtocolStub.headers)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = URLProtocolStub.responseData {
                self.client?.urlProtocol(self, didLoad: data)
            } else {
                self.client?.urlProtocol(self, didLoad: Data())
            }
