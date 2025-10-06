import XCTest
@testable import EfcRickMorty

final class TestEndPoint: XCTestCase {
    func test_character_page_builds_expected_url() {
        let url = EndPoint.character(.page("3")).urlString
        XCTAssertEqual(url, "https://rickandmortyapi.com/api/character/?page=3")
    }
}
