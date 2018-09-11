import XCTest
import RxTest
import RxSwift
import RxCocoa
import Domain
@testable import Search

final class SearchViewModelSpec: XCTestCase {
  
  private var sut: SearchViewModelType!
  private var searchGames: SearchGamesStub!
  private let scheduler = TestScheduler(initialClock: 0)
  private let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    searchGames = SearchGamesStub()
    sut = SearchViewModel(
      searchGames: searchGames
    )
  }
  
  func test_should_update_results_if_there_are_game_results() {
    let input = givenInput()

    sut.output.results
      .drive(input)
      .disposed(by: bag)
    
    searchGames.givenThereAreGameResults()
    
    sut.output.bind(to: .just("mario"))

    let expectedEvents = [
      next(0, searchGames.suggestions)
    ]

    XCTAssertEqual(input.events, expectedEvents)
  }
  
  func test_should_return_empty_list_if_there_are_any_errors() {
    let input = givenInput()
    
    sut.output.results
      .drive(input)
      .disposed(by: bag)
    
    searchGames.errorToThrow = .noInternet

    sut.output.bind(to: .just("mario"))
    
    let expectedEvents: [Recorded<Event<[GameSearchSuggestion]>>] = [
      next(0, [])
    ]
    
    XCTAssertEqual(input.events, expectedEvents)
  }
  
  // MARK: - Observers
  
  private func givenInput() -> TestableObserver<[GameSearchSuggestion]> {
    return scheduler.createObserver([GameSearchSuggestion].self)
  }
}
