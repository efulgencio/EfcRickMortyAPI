import XCTest
import Combine
@testable import EfcRickMorty

/// `TestCombineManager` contains unit tests to verify the behavior
/// of the `CombineManager` in simulated network operations.
///
/// `URLProtocolStub` is used to intercept network requests and return
/// controlled responses without the need for a real server.
final class TestCombineManager: XCTestCase {
    
    /// Set of Combine subscriptions that must be released
    /// at the end of each test.
    var cancellables = Set<AnyCancellable>()

    // MARK: - Test Lifecycle
    
    /// Sets up the test environment before each execution.
    /// - Registers `URLProtocolStub` to intercept all network requests.
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    /// Cleans up the environment after each test.
    /// - Unregisters the stub.
    /// - Clears the set of subscriptions.
    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Tests
    
    /// Verifies that when `CombineManager.getData` receives a successful HTTP response (200)
    /// with valid JSON (`jsonListDTO`), it is correctly decoded to `ListDTO`.
    ///
    /// - Steps tested:
    ///   1. `URLProtocolStub` is configured with `statusCode = 200` and valid data.
    ///   2. The `getData` call is made.
    ///   3. Expects the decoding to produce a valid `ListDTO`.
    ///   4. Validates that the first element has `id = 1`.
    func test_getData_success_decodes_ListDTO() {
        // Prepare mocked response
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
                    XCTAssertEqual(dto.results.first?.id, 1, "The first result must have id = 1")
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }

    /// Verifies that when `CombineManager.getData` receives an HTTP error response (404),
    /// a `NetworkError` is emitted and not a decoded value.
    ///
    /// - Steps tested:
    ///   1. `URLProtocolStub` is configured with `statusCode = 404` and empty data.
    ///   2. The `getData` call is made.
    ///   3. Expects the `sink` to receive a `.failure`.
    ///   4. Validates that **no** decoded value is received.
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
                    XCTFail("The call should not complete successfully in case of an HTTP error")
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }
}
