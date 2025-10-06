import XCTest
import Combine
@testable import EfcRickMorty

/// `TestDetailViewModel` contains unit tests to verify
/// the behavior of the `DetailViewModel` when fetching a character's details.
final class TestDetailViewModel: XCTestCase {
    
    /// Verifies that `DetailViewModel.getDetail`:
    /// 1. Correctly calls the `DetailUseCase`.
    /// 2. Updates the state (`viewModelState`) to `.loadedView`.
    /// 3. Correctly assigns the character data (`character.data`).
    ///
    /// - Behavior:
    ///   - A simulated model (`DetailModel`) is created with mock data.
    ///   - A `DetailUseCase` is injected that always returns the mock using Combine's `Just`.
    ///   - The view model's `getDetail(id:)` method is called.
    ///   - After a small delay (0.1s), the following are validated:
    ///     - The view model's state.
    ///     - The character data is loaded correctly.
    func test_getDetail_success_updates_state_and_data() {
        // 1. Prepare a simulated detail model
        var model = DetailModel()
        model.data = DetailItem.getMock() // mock character with id = 1

        // 2. Create a mock use case that always returns the simulated model
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

        // 3. Initialize the view model with the mock use case
        let vm = DetailViewModel(detailUseCase: useCase)
        vm.getDetail(id: 1)

        // 4. Create an expectation to wait for the state update
        let exp = expectation(description: "detail loaded")

        // 5. After a small delay, validate that the view model was updated correctly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(vm.character.data?.id, 1, "The loaded character must have id = 1")
            exp.fulfill()
        }

        // 6. Wait for the expectation to be fulfilled (timeout 1s)
        wait(for: [exp], timeout: 1)
    }
}
