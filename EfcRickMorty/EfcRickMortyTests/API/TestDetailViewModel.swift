import XCTest
import Combine
@testable import EfcRickMorty

final class TestDetailViewModel: XCTestCase {
    func test_getDetail_success_updates_state_and_data() {
        var model = DetailModel()
        model.data = DetailItem.getMock()

        let useCase = DetailUseCase(
            getCharacter: { _ in
                Just(model).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
            },
            getLocation: { _ in
                Just(model).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
            },
            getEpisode: {
                Just(model).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
            }
        )

        let vm = DetailViewModel(detailUseCase: useCase)
        vm.getDetail(id: 1)

        let exp = expectation(description: "detail loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(vm.viewModelState, .loadedView)
            XCTAssertEqual(vm.character.data?.id, 1)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
