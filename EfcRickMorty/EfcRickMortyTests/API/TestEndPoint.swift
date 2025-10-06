import XCTest
@testable import EfcRickMorty

/// `TestEndPoint` contains unit tests to verify
/// the correct URL construction for API endpoints.
final class TestEndPoint: XCTestCase {
    
    /// Verifies that when constructing a character endpoint with a specific page,
    /// the generated URL is the expected one.
    ///
    /// - Scenario tested:
    ///   - An endpoint `EndPoint.character(.page("3"))` is created.
    /// - Validation:
    ///   - The generated URL must be exactly `"https://rickandmortyapi.com/api/character/?page=3"`.
    func test_character_page_builds_expected_url() {
        let url = EndPoint.character(.page("3")).urlString
        XCTAssertEqual(url, "https://rickandmortyapi.com/api/character/?page=3", "The generated URL does not match the expected one")
    }
}
