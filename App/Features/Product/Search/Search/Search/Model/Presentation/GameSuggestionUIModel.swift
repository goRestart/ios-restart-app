import Domain
import IGListKit

final class GameSuggestionUIModel: NSObject, ListDiffable {

  private let suggestion: GameSearchSuggestion

  init(suggestion: GameSearchSuggestion) {
    self.suggestion = suggestion
  }

  var gameId: Identifier<Game> {
    return suggestion.id
  }

  var attributedTitle: NSAttributedString? {
    let name = suggestion.value
    let query = suggestion.query
    let attributedString = NSMutableAttributedString(string: name)

    do {
      let regex = try NSRegularExpression(pattern: query.trimmed.folding(options: .diacriticInsensitive, locale: .current), options: .caseInsensitive)
      let range = NSRange(location: 0, length: name.utf16.count)
      let matches = regex.matches(in: name.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range)
      let attributes: [NSAttributedStringKey: Any] = [
        .font: UIFont.body(.semibold),
        .foregroundColor: UIColor.primary
      ]
      for match in matches {
        attributedString.addAttributes(attributes, range: match.range)
      }
      return attributedString

    } catch { return nil }
  }

  // MARK: - ListDiffable
  
  func diffIdentifier() -> NSObjectProtocol {
    let uniqueIdentifier = "\(suggestion.id.value)\(suggestion.query)\(suggestion.value)"
    return uniqueIdentifier as NSObjectProtocol
  }
  
  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let object = object as? GameSuggestionUIModel else {
      return false
    }
    return object.suggestion == suggestion
  }
}
