import IGListKit

final class GameSuggestionSectionController: ListSectionController {
  
  private let suggestion: GameSuggestionViewRender
  
  init(suggestion: GameSuggestionViewRender) {
    self.suggestion = suggestion
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    return CGSize(
      width: collectionContext!.containerSize.width,
      height: GameSuggestionCell.height
    )
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext!.dequeueReusableCell(of: GameSuggestionCell.self, for: self, at: index) as? GameSuggestionCell else { fatalError() }
    cell.configure(with: suggestion)
    return cell
  }
}
