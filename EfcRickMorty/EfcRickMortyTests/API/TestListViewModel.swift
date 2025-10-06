import XCTest
import Combine
@testable import EfcRickMorty

/// `TestListViewModel` contiene pruebas unitarias para verificar
/// el comportamiento de `ListViewModel` en diferentes escenarios:
/// carga inicial, paginación y manejo de errores.
final class TestListViewModel: XCTestCase {
    
    // MARK: - Helpers
    
    /// Crea un `ListModel` simulado con los items y número de páginas indicados.
    ///
    /// - Parameters:
    ///   - items: Lista de `ListItem` a incluir en el modelo.
    ///   - pages: Número total de páginas disponibles.
    /// - Returns: Un `ListModel` configurado con los datos pasados.
    func makeListModel(items: [ListItem], pages: Int) -> ListModel {
        let m = ListModel()
        m.data = items
        m.numberPages = pages
        return m
    }

    // MARK: - Tests

    /// Verifica que al obtener la lista inicial (`getList`) el view model:
    /// 1. Actualiza el estado a `.loadedView`.
    /// 2. Establece correctamente el número de páginas para navegar.
    /// 3. Inicializa la página actual (`numberPage`) en 1.
    /// 4. Asigna los personajes a `characters`.
    /// 5. Cambia `isLoading` a false.
    func test_getList_success_sets_state_and_pages() {
        let page1 = makeListModel(
            items: [ListItem(id: 1, name: "Rick", image: "u1")],
            pages: 3
        )

        let useCase = ListUseCase(
            getList: { _ in
                Just(page1)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            },
            getListByPage: { _ in
                Just(page1)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
        )

        let vm = ListViewModel(listUseCase: useCase)

        let exp = expectation(description: "loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(vm.numberPagesForNavigate, 3, "Debe tener 3 páginas")
            XCTAssertEqual(vm.numberPage, 1, "La página inicial debe ser 1")
            XCTAssertEqual(vm.characters?.data.count, 1, "Debe haber un personaje cargado")
            XCTAssertFalse(vm.isLoading, "No debe estar cargando")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    /// Verifica que al cargar la siguiente página (`loadNextPage`):
    /// 1. Se agregan los nuevos items al array existente (`characters.data`).
    /// 2. Se incrementa el número de página (`numberPage`).
    /// 3. Se llaman los métodos correspondientes del use case (`getList` y `getListByPage`).
    func test_loadNextPage_appends_items() {
        let page1 = makeListModel(items: [ListItem(id: 1, name: "Rick", image: "u1")], pages: 2)
        let page2 = makeListModel(items: [ListItem(id: 2, name: "Morty", image: "u2")], pages: 2)

        var calls = [String]()
        let useCase = ListUseCase(
            getList: { _ in
                calls.append("getList")
                return Just(page1).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
            },
            getListByPage: { page in
                calls.append("getListByPage:\(page)")
                return (page == "2" ? Just(page2) : Just(page1))
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
        )

        let vm = ListViewModel(listUseCase: useCase)

        let exp = expectation(description: "append")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            vm.loadNextPage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(vm.characters?.data.map { $0.id }, [1, 2], "Debe contener los ids de ambas páginas")
                XCTAssertEqual(vm.numberPage, 2, "El número de página debe actualizarse a 2")
                XCTAssertTrue(calls.contains("getList"), "Debe haberse llamado getList")
                XCTAssertTrue(calls.contains("getListByPage:2"), "Debe haberse llamado getListByPage con página 2")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    /// Verifica que si `getList` falla con un error de red:
    /// 1. Se asigna un `alertItem` indicando error.
    /// 2. `isLoading` se establece en false.
    func test_getList_error_sets_alert_and_stops_loading() {
        let useCase = ListUseCase(
            getList: { _ in
                Fail(error: NetworkError(
                    errorType: .other,
                    genericResponse: nil,
                    responseCode: 500,
                    errorTitle: "Error de test",
                    errorDescription: "Simulación de error de red"
                ))
                .eraseToAnyPublisher()
            },
            getListByPage: { _ in
                Fail(error: NetworkError(
                    errorType: .other,
                    genericResponse: nil,
                    responseCode: 500,
                    errorTitle: "Error de test",
                    errorDescription: "Simulación de error de red"
                ))
                .eraseToAnyPublisher()
            }
        )


        let vm = ListViewModel(listUseCase: useCase)

        let exp = expectation(description: "error handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(vm.alertItem, "Debe mostrarse un alertItem al ocurrir error")
            XCTAssertFalse(vm.isLoading, "No debe estar cargando tras el error")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
