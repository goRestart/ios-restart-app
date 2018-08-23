import Domain
import IGListKit

protocol GameSuggestionListAdapterDelegate: class {
  func didSelectGameSuggestion(with id: Identifier<Game>)
}

final class GameSuggestionListAdapter: NSObject, ListAdapterDataSource {

  weak var delegate: GameSuggestionListAdapterDelegate?
  var suggestions = [GameSuggestionUIModel]()

  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return suggestions
  }
  
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    guard let object = object as? GameSuggestionUIModel else { fatalError() }
    let controller = GameSuggestionSectionController(suggestion: object)
    controller.delegate = self
    return controller
  }
  
  func emptyView(for listAdapter: ListAdapter) -> UIView? {
    return nil
  }
}

extension GameSuggestionListAdapter: GameSuggestionSectionControllerDelegate {
  func didSelectGameSuggestion(with id: Identifier<Game>) {
    delegate?.didSelectGameSuggestion(with: id)
  }
}

