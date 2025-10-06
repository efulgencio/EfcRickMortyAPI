import XCTest
import Combine
@testable import EfcRickMorty

final class TestListViewModel: XCTestCase {
    func makeListModel(items: [ListItem], pages: Int) -> ListModel {
        let m = ListModel()
        m.data = items
        m.numberPages = pages
        return m
    }

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
            XCTAssertEqual(vm.viewModelState, .loadedView)
            XCTAssertEqual(vm.numberPagesForNavigate, 3)
            XCTAssertEqual(vm.numberPage, 1)
            XCTAssertEqual(vm.characters?.data.count, 1)
            XCTAssertFalse(vm.isLoading)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

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
                XCTAssertEqual(vm.characters?.data.map { $0.id }, [1, 2])
                XCTAssertEqual(vm.numberPage, 2)
                XCTAssertTrue(calls.contains("getList"))
                XCTAssertTrue(calls.contains("getListByPage:2"))
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_getList_error_sets_alert_and_stops_loading() {
        let useCase = ListUseCase(
            getList: { _ in
                Fail(error: NetworkError.unknown)
                    .eraseToAnyPublisher()
            },
            getListByPage: { _ in
                Fail(error: NetworkError.unknown)
                    .eraseToAnyPublisher()
            }
        )

        let vm = ListViewModel(listUseCase: useCase)

        let exp = expectation(description: "error handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(vm.alertItem)
            XCTAssertFalse(vm.isLoading)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
