import UIKit

private struct AnimationDuration {
  static let highlight = 0.3
}

public enum LargeButtonType {
  case normal
  case alt
}

open class LargeButton: UIButton {
  
  public var type: LargeButtonType = .normal {
    didSet {
      configure(for: type)
    }
  }
  
  open override var isHighlighted: Bool {
    didSet {
      if isHighlighted { highlight() }
      if !isHighlighted { unhighlight() }
    }
  }
  
  // MARK: - Init
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: - Setup
  
  private func setup() {
    titleLabel?.font = .button
    titleLabel?.textAlignment = .center
    configure(for: type)
    applyConstraints()
  }
  
  // MARK: - Configure
  
  private func configure(for type: LargeButtonType) {
    switch type {
    case .normal:
      layer.borderWidth = 0
    case .alt:
      layer.borderWidth = 2
      layer.borderColor = UIColor.darkGrey.cgColor
    }
    backgroundColor = backgroundColor(isHighlighted: false)
  }
  
  
  // MARK: - Title
  
  open override func setTitle(_ title: String?, for state: UIControlState) {
    setAttributedTitle(attributed(title), for: state)
  }
  
  open override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControlState) {
    super.setAttributedTitle(attributed(title?.string), for: state)
  }
  
  private func attributed(_ title: String?) -> NSAttributedString {
    let foregroundColor = type == .normal ? UIColor.primary: UIColor.darkScript
    let attributes: [NSAttributedStringKey: Any] = [
      .font: UIFont.button,
      .foregroundColor: foregroundColor
    ]
    guard let title = title else { fatalError("Empty title") }
    return NSAttributedString(string: title.uppercased(), attributes: attributes)
  }
  
  // MARK: - Highlight
  
  private func highlight() {
    UIView.animate(withDuration: AnimationDuration.highlight) {
      let scale = CGFloat(0.98)
      self.transform = CGAffineTransform(scaleX: scale, y: scale)
      self.backgroundColor = self.backgroundColor(isHighlighted: true)
    }
  }
  
  private func unhighlight() {
    UIView.animate(withDuration: AnimationDuration.highlight) {
      self.transform = .identity
      self.backgroundColor = self.backgroundColor(isHighlighted: false)
    }
  }
  
  private func backgroundColor(isHighlighted: Bool) -> UIColor {
    switch type {
    case .normal:
      return isHighlighted ? UIColor.primary.withAlphaComponent(0.3): UIColor.primary.withAlphaComponent(0.1)
    case .alt:
      return isHighlighted ? .grease: .white
    }
  }
  
  // MARK: - Layout
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = Radius.big
  }
  
  private func applyConstraints() {
    titleLabel?.snp.remakeConstraints { make in
      let edge = UIEdgeInsets(top: Margin.medium, left: Margin.small, bottom: Margin.medium, right: Margin.small)
      make.edges.equalTo(self).inset(edge)
    }
  }
}
