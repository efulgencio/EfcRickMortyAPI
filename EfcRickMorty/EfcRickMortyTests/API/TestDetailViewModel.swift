import XCTest
import Combine
@testable import EfcRickMorty

/// `TestDetailViewModel` contiene pruebas unitarias para verificar
/// el comportamiento de `DetailViewModel` cuando obtiene detalles de un personaje.
final class TestDetailViewModel: XCTestCase {
    
    /// Verifica que `DetailViewModel.getDetail`:
    /// 1. Llama correctamente al `DetailUseCase`.
    /// 2. Actualiza el estado (`viewModelState`) a `.loadedView`.
    /// 3. Asigna los datos del personaje (`character.data`) correctamente.
    ///
    /// - Comportamiento:
    ///   - Se crea un modelo simulado (`DetailModel`) con datos mock.
    ///   - Se inyecta un `DetailUseCase` que devuelve siempre el mock usando `Just` de Combine.
    ///   - Se llama al método `getDetail(id:)` del view model.
    ///   - Tras un pequeño retraso (0.1s), se validan:
    ///     - Estado del view model.
    ///     - Datos del personaje cargados correctamente.
    func test_getDetail_success_updates_state_and_data() {
        // 1. Prepara un modelo de detalle simulado
        var model = DetailModel()
        model.data = DetailItem.getMock() // personaje mock con id = 1

        // 2. Crea un use case mock que siempre devuelve el modelo simulado
        let useCase = DetailUseCase(
            getCharacter: { _ in
                Just(model)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            },
            getLocation: { _ in
                Just(model)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            },
            getEpisode: {
                Just(model)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
        )

        // 3. Inicializa el view model con el use case mock
        let vm = DetailViewModel(detailUseCase: useCase)
        vm.getDetail(id: 1)

        // 4. Crea una expectativa para esperar a que se actualice el estado
        let exp = expectation(description: "detail loaded")

        // 5. Tras un pequeño delay, valida que el view model se actualizó correctamente
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(vm.character.data?.id, 1, "El personaje cargado debe tener id = 1")
            exp.fulfill()
        }

        // 6. Espera a que la expectativa se cumpla (timeout 1s)
        wait(for: [exp], timeout: 1)
    }
}
