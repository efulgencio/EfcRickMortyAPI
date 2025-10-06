import XCTest
import Combine
@testable import EfcRickMorty

/// `TestListViewModel` contains unit tests to verify
/// the behavior of `ListViewModel` in different scenarios:
/// initial loading, pagination, and error handling.
final class TestListViewModel: XCTestCase {
    
    // MARK: - Helpers
    
    /// Creates a mock `ListModel` with the specified items and number of pages.
    ///
    /// - Parameters:
    ///   - items: List of `ListItem` to include in the model.
    ///   - pages: Total number of available pages.
    /// - Returns: A `ListModel` configured with the provided data.
    func makeListModel(items: [ListItem], pages: Int) -> ListModel {
        let m = ListModel()
        m.data = items
        m.numberPages = pages
        return m
    }

    // MARK: - Tests

    /// Verifies that when fetching the initial list (`getList`) the view model:
    /// 1. Updates the state to `.loadedView`.
    /// 2. Correctly sets the number of pages for navigation.
    /// 3. Initializes the current page (`numberPage`) to 1.
    /// 4. Assigns the characters to `characters`.
    /// 5. Changes `isLoading` to false.
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
            XCTAssertEqual(vm.numberPagesForNavigate, 3, "Should have 3 pages")
            XCTAssertEqual(vm.numberPage, 1, "The initial page must be 1")
            XCTAssertEqual(vm.characters?.data.count, 1, "There should be one loaded character")
            XCTAssertFalse(vm.isLoading, "Should not be loading")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    /// Verifies that when loading the next page (`loadNextPage`):
    /// 1. New items are appended to the existing array (`characters.data`).
    /// 2. The page number is incremented (`numberPage`).
    /// 3. The corresponding use case methods (`getList` and `getListByPage`) are called.
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
                XCTAssertEqual(vm.characters?.data.map { $0.id }, [1, 2], "Must contain the IDs from both pages")
                XCTAssertEqual(vm.numberPage, 2, "The page number must be updated to 2")
                XCTAssertTrue(calls.contains("getList"), "getList should have been called")
                XCTAssertTrue(calls.contains("getListByPage:2"), "getListByPage should have been called with page 2")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    /// Verifies that if `getList` fails with a network error:
    /// 1. An `alertItem` indicating an error is assigned.
    /// 2. `isLoading` is set to false.
    func test_getList_error_sets_alert_and_stops_loading() {
        let useCase = ListUseCase(
            getList: { _ in
                Fail(error: NetworkError(
                    errorType: .other,
                    genericResponse: nil,
                    responseCode: 500,
                    errorTitle: "Test Error",
                    errorDescription: "Simulated network error"
                ))
                .eraseToAnyPublisher()
            },
            getListByPage: { _ in
                Fail(error: NetworkError(
                    errorType: .other,
                    genericResponse: nil,
                    responseCode: 500,
                    errorTitle: "Test Error",
                    errorDescription: "Simulated network error"
                ))
                .eraseToAnyPublisher()
            }
        )


        let vm = ListViewModel(listUseCase: useCase)

        let exp = expectation(description: "error handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(vm.alertItem, "An alertItem must be shown when an error occurs")
            XCTAssertFalse(vm.isLoading, "Should not be loading after the error")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
