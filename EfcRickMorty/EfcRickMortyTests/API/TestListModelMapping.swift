import XCTest
@testable import EfcRickMorty

/// `TestListModelMapping` contains unit tests to verify
/// the correct decoding and mapping from the DTO (`ListDTO`) to the domain model (`ListModel`).
final class TestListModelMapping: XCTestCase {
    
    /// Verifies that a `ListDTO` can:
    /// 1. Be decoded correctly from JSON.
    /// 2. Be mapped properly to the `ListModel` domain model.
    ///
    /// - Throws: Throws an error if JSON decoding fails.
    ///
    /// - Tested behavior:
    ///   - The number of pages (`numberPages`) is assigned correctly.
    ///   - The `data` collection contains the expected number of elements.
    ///   - The first element has the expected values (`id` and `name`).
    ///   - The last element has the expected `id`.
    func test_listDTO_decodes_and_maps_to_ListModel() throws {
        // 1. Decode the DTO from a mock JSON
        let dto = try JSONDecoder().decode(ListDTO.self, from: jsonListDTO)

        // 2. Map the DTO to your domain model
        let model = ListModel()
        model.fromDto(dto: dto)

        // 3. Validations (Asserts)
        XCTAssertEqual(model.numberPages, 42, "The number of pages should be 42")
        XCTAssertEqual(model.data.count, 2, "The model should contain 2 characters")
        XCTAssertEqual(model.data.first?.id, 1, "The first character should have id = 1")
        XCTAssertEqual(model.data.first?.name, "Rick Sanchez", "The first character should be Rick Sanchez")
        XCTAssertEqual(model.data.last?.id, 2, "The last character should have id = 2")
    }
}
