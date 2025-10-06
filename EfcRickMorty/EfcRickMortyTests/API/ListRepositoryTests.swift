//
//  ListRepositoryTests.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import XCTest
import Combine
@testable import EfcRickMorty // Reemplaza "EfcRickMorty" con el nombre de tu proyecto

final class ListRepositoryTests: XCTestCase {

    // Almacena las suscripciones de Combine para que no se liberen de memoria prematuramente.
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        // Inicializamos el set de cancellables antes de cada test.
        cancellables = []
    }

    override func tearDown() {
        // Limpiamos el set después de cada test.
        cancellables = nil
        super.tearDown()
    }

    func test_getListMock_whenDataIsLoaded_thenCharactersGenderShouldBeMale() {
        // 1. ARRANGE (Preparación)
        
        // Creamos una expectativa para manejar la llamada asíncrona del publicador.
        let expectation = XCTestExpectation(description: "Recibir personajes del mock y verificar el género.")
        
        // Usamos el mock que ya tienes definido. Este es nuestro "System Under Test" (SUT).
        let repositoryMock = ListRepository.mock
        
        var receivedCharacters: [Character] = []

        // 2. ACT (Acción)
        
        // Nos suscribimos al publicador devuelto por la función getList.
        // El parámetro `forFilter` puede ser cualquier string, ya que el mock no lo utiliza.
        repositoryMock.getList("")
            .sink(receiveCompletion: { completion in
                // Si la suscripción falla, el test debe fallar.
                if case .failure(let error) = completion {
                    XCTFail("La obtención de datos del mock falló con el error: \(error)")
                }
            }, receiveValue: { listDTO in
                // Guardamos los personajes recibidos.
                receivedCharacters = listDTO.results
                
                // La prueba ha recibido los datos, así que cumplimos la expectativa.
                expectation.fulfill()
            })
            .store(in: &cancellables) // Guardamos la suscripción.

        // Esperamos a que la expectativa se cumpla, con un timeout por si algo va mal.
        wait(for: [expectation], timeout: 1.0)
        
        // 3. ASSERT (Verificación)
        
        // Nos aseguramos de que hemos recibido personajes.
        XCTAssertFalse(receivedCharacters.isEmpty, "No se recibieron personajes del mock.")
        
        // Verificamos que CADA personaje en la lista recibida tiene el género "Male".
        for character in receivedCharacters {
            XCTAssertEqual(character.species, "Human", "El género del personaje \(character.name) es 'Human'.")
        }
    }
}
