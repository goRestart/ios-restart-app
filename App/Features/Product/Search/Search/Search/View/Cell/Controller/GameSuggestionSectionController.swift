import IGListKit
import RxCocoa

final class GameSuggestionSectionController: ListSectionController {
 
  private var suggestion: GameSuggestionUIModel
  private let state: PublishRelay<GameSuggestionEvent>
  
  init(suggestion: GameSuggestionUIModel,
       state: PublishRelay<GameSuggestionEvent>)
  {
    self.suggestion = suggestion
    self.state = state
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    return CGSize(
      width: collectionContext!.containerSize.width,
      height: GameSuggestionCell.height
    )
  }

  override func didSelectItem(at index: Int) {
    state.accept(.gameSelected(suggestion.title, suggestion.gameId))
  }

  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext!.dequeueReusableCell(of: GameSuggestionCell.self, for: self, at: index) as? GameSuggestionCell else { fatalError() }
    cell.configure(with: suggestion)
    return cell
  }
  
  override func didUpdate(to object: Any) {
    guard let object = object as? GameSuggestionUIModel else { return }
    self.suggestion = object
  }
}
