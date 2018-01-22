import XCTest
import RxTest
import RxCocoa
import Domain
@testable import Search

final class SearchViewModelSpec: XCTestCase {
  
  private var sut: SearchViewModelType!
  private var searchGames: SearchGamesStub!
  private let scheduler = TestScheduler(initialClock: 0)
  
  override func setUp() {
    super.setUp()
    searchGames = SearchGamesStub()
    sut = SearchViewModel(
      searchGames: searchGames
    )
  }
  
  override func tearDown() {
    searchGames = nil
    sut = nil
    super.tearDown()
  }
  
  func test_should_update_results_if_there_are_game_results() {
    let inputObserver = scheduler.createObserver([GameSearchSuggestion].self)

    _ = sut.output.results.asObservable().bind(to: inputObserver)
    
    searchGames.givenThereAreGameResults()

    sut.output.bind(to: .just("mario"))

    let expectedValues = [
      next(0, []),
      next(0, searchGames.suggestions)
    ]

    XCTAssertEqual(inputObserver.events.count, expectedValues.count)
    XCTAssertEqual(inputObserver.events.first!.value.element!, [])
    XCTAssertEqual(inputObserver.events.last!.value.element!, searchGames.suggestions)
  }
  
  func test_should_return_empty_list_if_there_are_any_errors() {
    let inputObserver = scheduler.createObserver([GameSearchSuggestion].self)

    _ = sut.output.results.asObservable().bind(to: inputObserver)
    
    searchGames.errorToThrow = .noInternet

    sut.output.bind(to: .just("mario"))

    let expectedValues = [
      next(0, []),
      next(0, searchGames.suggestions)
    ]

    XCTAssertEqual(inputObserver.events.count, expectedValues.count)
    XCTAssertEqual(inputObserver.events.first!.value.element!, [])
    XCTAssertEqual(inputObserver.events.last!.value.element!, [])
  }
}

