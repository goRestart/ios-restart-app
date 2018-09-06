import IGListKit
import RxCocoa
import UIKit

final class GameSuggestionListAdapter: NSObject, ListAdapterDataSource {

  private var suggestions = [GameSuggestionUIModel]()

  private let state: PublishRelay<GameSuggestionEvent>

  init(state: PublishRelay<GameSuggestionEvent>) {
    self.state = state
  }
  
  func set(_ suggestions: [GameSuggestionUIModel]) {
    self.suggestions = suggestions
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
