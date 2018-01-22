import IGListKit

final class GameSuggestionListAdapter: NSObject, ListAdapterDataSource {
  
  var suggestions = [GameSuggestionViewRender]()

  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return suggestions
  }
  
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    guard let object = object as? GameSuggestionViewRender else { fatalError() }
    return GameSuggestionSectionController(suggestion: object)
  }
  
  func emptyView(for listAdapter: ListAdapter) -> UIView? {
    return nil
  }
}
