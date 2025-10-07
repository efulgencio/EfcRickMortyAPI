//
//  ListRepositoryTests.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import XCTest
import Combine
@testable import EfcRickMorty


/// `ListRepositoryTests` contains unit tests for verifying the behavior of the
/// `ListRepository` when retrieving a list of characters.
///
/// These tests ensure that the mock repository correctly loads data and that
/// the received characters have the expected properties (in this case, species and gender).
///
/// The tests use Combine to handle asynchronous data streams and `XCTestExpectation`
/// to wait for data emission before performing assertions.
final class ListRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    
    /// A set of Combine subscriptions used to store publishers during testing.
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
    
    /// Verifies that when retrieving a character list from the mock repository,
    /// all received characters have the expected species and gender.
    ///
    /// The test:
    /// - Calls `getList(_:)` with an empty filter.
    /// - Waits for the mock repository to emit a list of characters.
    /// - Asserts that the list is not empty.
    /// - Validates that each character’s `species` equals `"Human"`.
    ///
    /// If no data is received or a character has an unexpected value, the test fails.
    func test_getListMock_whenDataIsLoaded_thenCharactersGenderShouldBeMale() {
        // 1. Create an expectation for the asynchronous call
        let expectation = XCTestExpectation(description: "Receive characters from the mock and verify the gender.")
        
        // 2. Create the mock repository instance
        let repositoryMock = ListRepository.mock
        
        // 3. Prepare a variable to store received data
        var receivedCharacters: [Character] = []

        // 4. Perform the call and subscribe to the publisher
        repositoryMock.getList("")
            .sink(receiveCompletion: { completion in
                // Fail the test if an error occurs
                if case .failure(let error) = completion {
                    XCTFail("Fetching data from the mock failed with error: \(error)")
                }
            }, receiveValue: { listDTO in
                // Store received characters and fulfill the expectation
                receivedCharacters = listDTO.results
                expectation.fulfill()
            })
            .store(in: &cancellables)

        // 5. Wait for the asynchronous operation to complete
        wait(for: [expectation], timeout: 1.0)
        
        // 6. Assertions
        XCTAssertFalse(receivedCharacters.isEmpty, "No characters were received from the mock.")
        
        for character in receivedCharacters {
            XCTAssertEqual(character.species, "Human", "The species of character \(character.name) should be 'Human'.")
        }
    }
}
