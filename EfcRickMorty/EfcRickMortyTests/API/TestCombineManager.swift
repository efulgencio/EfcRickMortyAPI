import XCTest
import Combine
@testable import EfcRickMorty

final class TestCombineManager: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        cancellables.removeAll()
        super.tearDown()
    }

    func test_getData_success_decodes_ListDTO() {
        // Prepara respuesta simulada
        URLProtocolStub.statusCode = 200
        URLProtocolStub.responseData = jsonListDTO

        let exp = expectation(description: "decode success")
        CombineManager.shared
            .getData(endpoint: EndPoint.character(.all), type: ListDTO.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let err) = completion {
                    XCTFail("Unexpected error: \(err)")
                }
            }, receiveValue: { dto in
                XCTAssertEqual(dto.results.first?.id, 1)
                exp.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }

    func test_getData_http_error_maps_to_NetworkError() {
        URLProtocolStub.statusCode = 404
        URLProtocolStub.responseData = Data()

        let exp = expectation(description: "http error")
        CombineManager.shared
            .getData(endpoint: EndPoint.character(.all), type: ListDTO.self)
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                    exp.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not succeed")
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }
}
