//
//  Testc.swift
//  EfcRickMortyTests
//
//  Created by efulgencio on 6/10/25.
//

import XCTest

@testable import EfcRickMorty


final class TestListFeature: XCTestCase {

    // System Under Test: the object we are going to test
    var sut: CombineManager!
    
    // Runs before each test
    override func setUpWithError() throws {
        super.setUp()
        sut = CombineManager.shared  // Initializes CombineManager
    }

    // Runs after each test
    override func tearDownWithError() throws {
        sut = nil  // Frees up resources
        super.tearDown()
    }

    // Test that checks if the first character returned by the API has id = 1
    func testGetList_idFirst_equal_one() throws {

        // Create an expectation for the asynchronous call
        let expectation = self.expectation(description: "Waits for the API result")
        
        // API call using Combine
        let cancellabe = sut.getData(endpoint: EndPoint.character(.all), type: ListDTO.self).sink (
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // If it finishes correctly, the expectation is fulfilled
                    expectation.fulfill()
                case .failure(let error):
                    // If there is an error, the test fails
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                // Check the first character
                XCTAssertEqual(response.results[0].id, 1)
            })
        
        // Maximum wait of 10 seconds for the expectation to be fulfilled
        waitForExpectations(timeout: 10, handler: nil)
        cancellabe.cancel()  // Cancel the subscription to clean up memory
    }
    
    // Test that checks the pagination of page 3
    func testGetList_pageNumberThree_previousTwo_nextFour() throws {

        // Expected URLs for pagination
        let previousUrl = "https://rickandmortyapi.com/api/character/?page=2"
        let nextUrl = "https://rickandmortyapi.com/api/character/?page=4"
        
        // Create an expectation for the asynchronous call
        let expectation = self.expectation(description: "Waits for the API result")
        
        // API call for page 3
        let cancellabe = sut.getData(endpoint: EndPoint.character(.page("3")), type: ListDTO.self).sink (
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // If it finishes correctly, the expectation is fulfilled
                    expectation.fulfill()
                case .failure(let error):
                    // If there is an error, the test fails
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                // Check pagination URLs
                XCTAssertEqual(response.info.prev, previousUrl)
                XCTAssertEqual(response.info.next, nextUrl)
            })
        
        // Maximum wait of 10 seconds
        waitForExpectations(timeout: 10, handler: nil)
        cancellabe.cancel()  // Cancel the subscription
    }

}
