import Domain
import IGListKit

protocol GameSuggestionSectionControllerDelegate: class {
  func didSelectGameSuggestion(with id: Identifier<Game>)
}

final class GameSuggestionSectionController: ListSectionController {

  weak var delegate: GameSuggestionSectionControllerDelegate?

  private var suggestion: GameSuggestionUIModel
  
  init(suggestion: GameSuggestionUIModel) {
    self.suggestion = suggestion
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    return CGSize(
      width: collectionContext!.containerSize.width,
      height: GameSuggestionCell.height
    )
  }

  override func didSelectItem(at index: Int) {
    delegate?.didSelectGameSuggestion(with: suggestion.gameId)
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
