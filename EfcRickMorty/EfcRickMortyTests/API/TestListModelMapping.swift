import XCTest
@testable import EfcRickMorty

/// `TestListModelMapping` contiene pruebas unitarias para verificar
/// la correcta decodificación y mapeo del DTO (`ListDTO`) hacia el modelo de dominio (`ListModel`).
final class TestListModelMapping: XCTestCase {
    
    /// Verifica que un `ListDTO` puede:
    /// 1. Ser decodificado correctamente desde JSON.
    /// 2. Mapearse adecuadamente al modelo de dominio `ListModel`.
    ///
    /// - Throws: Lanza error si la decodificación del JSON falla.
    ///
    /// - Comportamiento probado:
    ///   - El número de páginas (`numberPages`) se asigna correctamente.
    ///   - La colección `data` contiene el número esperado de elementos.
    ///   - El primer elemento tiene los valores esperados (`id` y `name`).
    ///   - El último elemento tiene el `id` esperado.
    func test_listDTO_decodes_and_maps_to_ListModel() throws {
        // 1. Decodifica el DTO desde un JSON simulado
        let dto = try JSONDecoder().decode(ListDTO.self, from: jsonListDTO)

        // 2. Mapea el DTO a tu modelo de dominio
        let model = ListModel()
        model.fromDto(dto: dto)

        // 3. Validaciones (Asserts)
        XCTAssertEqual(model.numberPages, 42, "El número de páginas debe ser 42")
        XCTAssertEqual(model.data.count, 2, "El modelo debe contener 2 personajes")
        XCTAssertEqual(model.data.first?.id, 1, "El primer personaje debe tener id = 1")
        XCTAssertEqual(model.data.first?.name, "Rick Sanchez", "El primer personaje debe ser Rick Sanchez")
        XCTAssertEqual(model.data.last?.id, 2, "El último personaje debe tener id = 2")
    }
}
