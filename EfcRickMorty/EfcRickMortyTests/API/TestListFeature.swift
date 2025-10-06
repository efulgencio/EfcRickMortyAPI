//
//  Testc.swift
//  EfcRickMortyTests
//
//  Created by efulgencio on 21/4/24.
//

import XCTest

@testable import EfcRickMorty


final class TestListFeature: XCTestCase {

    // System Under Test: el objeto que vamos a testear
    var sut: CombineManager!
    
    // Se ejecuta antes de cada test
    override func setUpWithError() throws {
        super.setUp()
        sut = CombineManager.shared  // Inicializa CombineManager
    }

    // Se ejecuta después de cada test
    override func tearDownWithError() throws {
        sut = nil  // Libera recursos
        super.tearDown()
    }

    // Test que comprueba que el primer personaje devuelto por la API tiene id = 1
    func testGetList_idFirst_equal_one() throws {

        // Crear expectativa para la llamada asíncrona
        let expectation = self.expectation(description: "Espera el resultado de la API")
        
        // Llamada al API usando Combine
        let cancellabe = sut.getData(endpoint: EndPoint.character(.all), type: ListDTO.self).sink (
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // Si finaliza correctamente, se cumple la expectativa
                    expectation.fulfill()
                case .failure(let error):
                    // Si hay error, el test falla
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                // Comprobación del primer personaje
                XCTAssertEqual(response.results[0].id, 1)
            })
        
        // Espera máxima de 10 segundos para que se cumpla la expectativa
        waitForExpectations(timeout: 10, handler: nil)
        cancellabe.cancel()  // Cancela la suscripción para limpiar memoria
    }
    
    // Test que comprueba la paginación de la página 3
    func testGetList_pageNumberThree_previousTwo_nextFour() throws {

        // URLs esperadas para la paginación
        let previousUrl = "https://rickandmortyapi.com/api/character/?page=2"
        let nextUrl = "https://rickandmortyapi.com/api/character/?page=4"
        
        // Crear expectativa para la llamada asíncrona
        let expectation = self.expectation(description: "Espera el resultado de la API")
        
        // Llamada al API para la página 3
        let cancellabe = sut.getData(endpoint: EndPoint.character(.page("3")), type: ListDTO.self).sink (
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // Si finaliza correctamente, se cumple la expectativa
                    expectation.fulfill()
                case .failure(let error):
                    // Si hay error, el test falla
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                // Comprobación de URLs de paginación
                XCTAssertEqual(response.info.prev, previousUrl)
                XCTAssertEqual(response.info.next, nextUrl)
            })
        
        // Espera máxima de 10 segundos
        waitForExpectations(timeout: 10, handler: nil)
        cancellabe.cancel()  // Cancela la suscripción
    }

}
