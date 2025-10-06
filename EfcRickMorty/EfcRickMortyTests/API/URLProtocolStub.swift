import Foundation

final class URLProtocolStub: URLProtocol {
    static var responseData: Data?
    static var statusCode: Int = 200
    static var headers: [String: String] = [:]
    static var requestCount: Int = 0
    static var error: Error?
    static var responseDelay: TimeInterval = 0

    override class func canInit(with request: URLRequest) -> Bool {
        // Intercepta todas las peticiones
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

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
            self.client?.urlProtocolDidFinishLoading(self)
        }

        if URLProtocolStub.responseDelay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + URLProtocolStub.responseDelay, execute: respond)
        } else {
            respond()
        }
    }

    override func stopLoading() {}
}
