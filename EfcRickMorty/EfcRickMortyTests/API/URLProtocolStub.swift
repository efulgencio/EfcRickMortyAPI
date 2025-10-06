import Foundation

/// `URLProtocolStub` es un `URLProtocol` personalizado para interceptar peticiones de red
/// en tests unitarios. Permite simular respuestas HTTP con datos, errores o retrasos.
final class URLProtocolStub: URLProtocol {
    
    /// Datos a devolver en la respuesta simulada.
    static var responseData: Data?
    
    /// Código de estado HTTP de la respuesta (por defecto 200).
    static var statusCode: Int = 200
    
    /// Cabeceras HTTP de la respuesta simulada.
    static var headers: [String: String] = [:]
    
    /// Contador de peticiones interceptadas (útil para validar en tests).
    static var requestCount: Int = 0
    
    /// Error a devolver en lugar de una respuesta correcta (simula fallos de red).
    static var error: Error?
    
    /// Tiempo de espera artificial antes de responder (simula latencia de red).
    static var responseDelay: TimeInterval = 0

    // MARK: - URLProtocol Overrides
    
    /// Determina si este protocolo puede manejar una petición dada.
    ///
    /// - Parameter request: La `URLRequest` que se va a evaluar.
    /// - Returns: `true` para indicar que se interceptan todas las peticiones.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    /// Devuelve la request "canónica", es decir, la versión estándar de la petición.
    ///
    /// - Parameter request: La `URLRequest` original.
    /// - Returns: La misma request sin modificaciones.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    /// Inicia la carga de la petición interceptada.
    /// Simula la respuesta devolviendo datos, cabeceras y código HTTP o un error si está configurado.
    ///
    /// - Comportamiento:
    ///   1. Valida la URL de la request.
    ///   2. Incrementa el contador de peticiones.
    ///   3. Si se configuró un error, lo devuelve al cliente.
    ///   4. Si no, construye un `HTTPURLResponse` con `statusCode` y `headers`.
    ///   5. Devuelve los datos (`responseData` o vacío).
    ///   6. Marca la carga como finalizada.
    ///   7. Si hay `responseDelay`, espera ese tiempo antes de responder.
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

    /// Detiene la carga de la petición.
    /// - Nota: En este stub no es necesario implementar lógica de cancelación.
    override func stopLoading() {}
}
