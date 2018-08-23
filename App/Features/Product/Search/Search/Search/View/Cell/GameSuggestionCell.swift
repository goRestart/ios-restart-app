import UI

final class GameSuggestionCell: CollectionViewCell {

  static let height = CGFloat(48)

  private let suggestionLabel: UILabel = {
    let label = UILabel()
    label.font = .body(.regular)
    label.textColor = .darkScript
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func setupView() {
    addSubview(suggestionLabel)
  }
  
  override func setupConstraints() {
    suggestionLabel.snp.makeConstraints { make in
      make.left.equalTo(self).offset(Margin.medium)
      make.right.equalTo(self).offset(-Margin.medium)
      make.centerY.equalTo(self)
    }
  }
  
  func configure(with suggestion: GameSuggestionUIModel) {
    suggestionLabel.attributedText = suggestion.attributedTitle
  }
}
