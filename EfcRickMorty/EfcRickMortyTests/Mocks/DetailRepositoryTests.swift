//
//  DetailRepositoryTests.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import XCTest
import Combine
@testable import EfcRickMorty

/// `DetailRepositoryTests` contains unit tests for verifying
/// the behavior of the `DetailRepository` when fetching character details.
///
/// These tests ensure that mock data is correctly loaded
/// and that the returned `DetailDTO` model matches the expected values.
///
/// Combine is used to handle asynchronous data streams,
/// and `XCTestExpectation` ensures the test waits for completion
/// before asserting results.
final class DetailRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    
    /// A set of active Combine subscriptions used to store publishers during tests.
    var cancellables: Set<AnyCancellable>!

    // MARK: - Lifecycle
    
    /// Sets up the test environment before each test.
    /// Initializes the Combine cancellables set.
    override func setUp() {
        super.setUp()
        cancellables = []
    }

    /// Cleans up the test environment after each test.
    /// Releases Combine subscriptions and calls the superclass tearDown.
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    /// Verifies that when fetching a character from the mock repository,
    /// the received data matches the expected character details.
    ///
    /// The test:
    /// - Calls `getCharacter(_:)` with a known character ID.
    /// - Waits for the publisher to emit a value.
    /// - Checks that the received `DetailDTO` has the correct `id`, `name`, and `status`.
    ///
    /// If the fetch fails or the data is incorrect, the test fails.
    func test_getCharacterMock_whenDataIsLoaded_thenCharacterDetailsShouldBeCorrect() {
        // 1. Create an expectation for the asynchronous call
        let expectation = XCTestExpectation(description: "Receive character from mock and verify its details.")
        
        // 2. Create the mock repository instance
        let repositoryMock = DetailRepository.mock
        
        // 3. Expected and received variables
        var receivedCharacter: DetailDTO?
        let expectedName = "Rick Sanchez"
        let expectedId = 1
        
        // 4. Perform the call and subscribe to the publisher
        repositoryMock.getCharacter(expectedId)
            .sink(receiveCompletion: { completion in
                // Fail the test if an error occurs
                if case .failure(let error) = completion {
                    XCTFail("Fetching data from the mock failed with error: \(error)")
                }
            }, receiveValue: { detailDTO in
                // Store the received value and fulfill the expectation
                receivedCharacter = detailDTO
                expectation.fulfill()
            })
            .store(in: &cancellables)

        // 5. Wait for the asynchronous operation to complete
        wait(for: [expectation], timeout: 1.0)
        
        // 6. Assertions
        XCTAssertNotNil(receivedCharacter, "No character was received from the mock.")
        XCTAssertEqual(receivedCharacter?.id, expectedId, "The character's ID must be \(expectedId).")
        XCTAssertEqual(receivedCharacter?.name, expectedName, "The character's name must be '\(expectedName)'.")
        XCTAssertEqual(receivedCharacter?.status, "Alive", "The character's status must be 'Alive'.")
    }
}
