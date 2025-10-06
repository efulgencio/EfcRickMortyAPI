//
//  ListRepositoryTests.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import XCTest
import Combine
@testable import EfcRickMorty

final class ListRepositoryTests: XCTestCase {

    // Stores the Combine subscriptions so they are not prematurely deallocated.
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        // We initialize the set of cancellables before each test.
        cancellables = []
    }

    override func tearDown() {
        // We clear the set after each test.
        cancellables = nil
        super.tearDown()
    }

    func test_getListMock_whenDataIsLoaded_thenCharactersGenderShouldBeMale() {
        // 1. ARRANGE
        
        // We create an expectation to handle the asynchronous call of the publisher.
        let expectation = XCTestExpectation(description: "Receive characters from the mock and verify the gender.")
        
        // We use the mock you already have defined. This is our "System Under Test" (SUT).
        let repositoryMock = ListRepository.mock
        
        var receivedCharacters: [Character] = []

        // 2. ACT
        
        // We subscribe to the publisher returned by the getList function.
        // The `forFilter` parameter can be any string, as the mock does not use it.
        repositoryMock.getList("")
            .sink(receiveCompletion: { completion in
                // If the subscription fails, the test must fail.
                if case .failure(let error) = completion {
                    XCTFail("Fetching data from the mock failed with error: \(error)")
                }
            }, receiveValue: { listDTO in
                // We save the received characters.
                receivedCharacters = listDTO.results
                
                // The test has received the data, so we fulfill the expectation.
                expectation.fulfill()
            })
            .store(in: &cancellables) // We store the subscription.

        // We wait for the expectation to be fulfilled, with a timeout in case something goes wrong.
        wait(for: [expectation], timeout: 1.0)
        
        // 3. ASSERT
        
        // We make sure that we have received characters.
        XCTAssertFalse(receivedCharacters.isEmpty, "No characters were received from the mock.")
        
        // We verify that EVERY character in the received list has the species "Human".
        for character in receivedCharacters {
            XCTAssertEqual(character.species, "Human", "The species of character \(character.name) should be 'Human'.")
        }
    }
}
