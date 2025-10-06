import XCTest
@testable import EfcRickMorty

final class TestListModelMapping: XCTestCase {
    func test_listDTO_decodes_and_maps_to_ListModel() throws {
        // Decodifica el DTO
        let dto = try JSONDecoder().decode(ListDTO.self, from: jsonListDTO)

        // Mapea a tu modelo de dominio
        let model = ListModel()
        model.fromDto(dto: dto)

        // Asserts
        XCTAssertEqual(model.numberPages, 42)
        XCTAssertEqual(model.data.count, 2)
        XCTAssertEqual(model.data.first?.id, 1)
        XCTAssertEqual(model.data.first?.name, "Rick Sanchez")
        XCTAssertEqual(model.data.last?.id, 2)
    }
}
