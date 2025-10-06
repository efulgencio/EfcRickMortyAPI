//
//  DetailRepositoryTests.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import XCTest
import Combine
@testable import EfcRickMorty

final class DetailRepositoryTests: XCTestCase {

    // Stores Combine subscriptions to prevent them from being deallocated prematurely.
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        // We initialize the set of 'cancellables' before each test.
        cancellables = []
    }

    override func tearDown() {
        // We clean up the set after each test.
        cancellables = nil
        super.tearDown()
    }
    
    // Test to verify that the mock returns the character with the correct ID and name.
    func test_getCharacterMock_whenDataIsLoaded_thenCharacterDetailsShouldBeCorrect() {
        // 1. ARRANGE (Setup)
        
        // We create an expectation to handle the asynchronous call from the publisher.
        let expectation = XCTestExpectation(description: "Receive character from mock and verify its details.")
        
        // We use the mock you have already defined. This is our "System Under Test" (SUT).
        let repositoryMock = DetailRepository.mock
        
        var receivedCharacter: DetailDTO?
        let expectedName = "Rick Sanchez"
        let expectedId = 1
        
        // 2. ACT (Action)
        
        // We subscribe to the publisher returned by the getCharacter function.
        // The `id` parameter can be any integer, as the mock doesn't actually use it,
        // but we pass 1 by convention, which is the ID of the mock character.
        repositoryMock.getCharacter(expectedId)
            .sink(receiveCompletion: { completion in
                // If the subscription fails, the test must fail.
                if case .failure(let error) = completion {
                    XCTFail("Fetching data from the mock failed with error: \(error)")
                }
            }, receiveValue: { detailDTO in
                // We save the received character.
                receivedCharacter = detailDTO
                
                // The test has received the data, so we fulfill the expectation.
                expectation.fulfill()
            })
            .store(in: &cancellables) // We store the subscription.

        // We wait for the expectation to be fulfilled, with a timeout in case something goes wrong.
        wait(for: [expectation], timeout: 1.0)
        
        // 3. ASSERT (Verification)
        
        // We assert that a character was received.
        XCTAssertNotNil(receivedCharacter, "No character was received from the mock.")
        
        // We verify that the ID of the received character matches the expected one.
        XCTAssertEqual(receivedCharacter?.id, expectedId, "The character's ID must be \(expectedId).")
        
        // We verify that the name of the received character matches the expected one.
        XCTAssertEqual(receivedCharacter?.name, expectedName, "The character's name must be '\(expectedName)'.")
        
        // We can also verify other fields, such as the status.
        XCTAssertEqual(receivedCharacter?.status, "Alive", "The character's status must be 'Alive'.")
    }
    
    // If your `DetailRepository` has a `DetailDTO` implementation for `getLocation` and `getEpisode`
    // (even though the current mock always returns the character details, not location/episode details),
    // you could add similar tests for those functions:
    
    /*
    func test_getLocationMock_whenDataIsLoaded_thenDetailsShouldBeCorrect() {
        // ... (Implementation similar to the previous one for `repositoryMock.getLocation(1)`)
    }
    
    func test_getEpisodeMock_whenDataIsLoaded_thenDetailsShouldBeCorrect() {
        // ... (Implementation similar to the previous one for `repositoryMock.getEpisode()`)
    }
    */
}
