import XCTest
@testable import EfcRickMorty

/// `TestEndPoint` contiene pruebas unitarias para verificar
/// la correcta construcción de URLs en los endpoints de la API.
final class TestEndPoint: XCTestCase {
    
    /// Verifica que al construir un endpoint de personajes con página específica,
    /// la URL generada sea la esperada.
    ///
    /// - Escenario probado:
    ///   - Se crea un endpoint `EndPoint.character(.page("3"))`.
    /// - Validación:
    ///   - La URL generada debe ser exactamente `"https://rickandmortyapi.com/api/character/?page=3"`.
    func test_character_page_builds_expected_url() {
        let url = EndPoint.character(.page("3")).urlString
        XCTAssertEqual(url, "https://rickandmortyapi.com/api/character/?page=3", "La URL generada no coincide con la esperada")
    }
}
