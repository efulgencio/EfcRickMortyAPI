import XCTest
import Combine
@testable import EfcRickMorty

/// `TestCombineManager` contiene pruebas unitarias para verificar
/// el comportamiento del `CombineManager` en operaciones de red simuladas.
///
/// Se utiliza `URLProtocolStub` para interceptar peticiones de red y devolver
/// respuestas controladas sin necesidad de un servidor real.
final class TestCombineManager: XCTestCase {
    
    /// Conjunto de suscripciones de Combine que deben liberarse
    /// al finalizar cada test.
    var cancellables = Set<AnyCancellable>()

    // MARK: - Ciclo de vida del test
    
    /// Configura el entorno de pruebas antes de cada ejecución.
    /// - Registra `URLProtocolStub` para que intercepte todas las peticiones de red.
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    /// Limpia el entorno después de cada prueba.
    /// - Elimina el registro del stub.
    /// - Vacía el conjunto de suscripciones.
    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Tests
    
    /// Verifica que cuando `CombineManager.getData` recibe una respuesta HTTP exitosa (200)
    /// con un JSON válido (`jsonListDTO`), se decodifica correctamente a `ListDTO`.
    ///
    /// - Pasos probados:
    ///   1. Se configura el `URLProtocolStub` con `statusCode = 200` y datos válidos.
    ///   2. Se hace la llamada a `getData`.
    ///   3. Se espera que la decodificación produzca un `ListDTO` válido.
    ///   4. Se valida que el primer elemento tenga `id = 1`.
    func test_getData_success_decodes_ListDTO() {
        // Prepara respuesta simulada
        URLProtocolStub.statusCode = 200
        URLProtocolStub.responseData = jsonListDTO

        let exp = expectation(description: "decode success")
        
        CombineManager.shared
            .getData(endpoint: EndPoint.character(.all), type: ListDTO.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let err) = completion {
                        XCTFail("Unexpected error: \(err)")
                    }
                },
                receiveValue: { dto in
                    XCTAssertEqual(dto.results.first?.id, 1, "El primer resultado debe tener id = 1")
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }

    /// Verifica que cuando `CombineManager.getData` recibe una respuesta HTTP con error (404),
    /// se emite un `NetworkError` y no un valor decodificado.
    ///
    /// - Pasos probados:
    ///   1. Se configura el `URLProtocolStub` con `statusCode = 404` y datos vacíos.
    ///   2. Se hace la llamada a `getData`.
    ///   3. Se espera que el `sink` reciba un `.failure`.
    ///   4. Se valida que **no** se reciba ningún valor decodificado.
    func test_getData_http_error_maps_to_NetworkError() {
        URLProtocolStub.statusCode = 404
        URLProtocolStub.responseData = Data()

        let exp = expectation(description: "http error")
        
        CombineManager.shared
            .getData(endpoint: EndPoint.character(.all), type: ListDTO.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(_) = completion {
                        exp.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("La llamada no debería completarse con éxito en caso de error HTTP")
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }
}
