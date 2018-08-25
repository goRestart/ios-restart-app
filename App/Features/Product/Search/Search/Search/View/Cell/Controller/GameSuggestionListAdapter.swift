import IGListKit
import RxSwift

final class GameSuggestionListAdapter: NSObject, ListAdapterDataSource {

  var suggestions = [GameSuggestionUIModel]()

  private let state: PublishSubject<GameSuggestionEvent>

  init(state: PublishSubject<GameSuggestionEvent>) {
    self.state = state
  }
  
  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return suggestions
  }
  
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    guard let object = object as? GameSuggestionUIModel else { fatalError() }
    return GameSuggestionSectionController(
      suggestion: object,
      state: state
    )
  }
  
  func emptyView(for listAdapter: ListAdapter) -> UIView? {
    return nil
  }
}
