import UIKit

private struct InputConstraints {
  static let height = CGFloat(48)
  static let border = CGFloat(1)
  static let xPadding = CGFloat(10)
  static let yPadding = CGFloat(8)
}

open class Input: UITextField {
  open override var placeholder: String? {
    didSet {
      set(placeholder: placeholder)
    }
  }
  
  public var placeholderColor: UIColor? {
    didSet {
      set(placeholder: placeholder)
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
    font = .body(.regular)
    layer.cornerRadius = Radius.big
    backgroundColor = .softGrey
    clearButtonMode = .whileEditing
    textColor = .primary
    tintColor = .primary
    
    applyConstraints()
  }
  
  private func applyConstraints() {
    snp.makeConstraints { make in
      make.height.equalTo(InputConstraints.height)
    }
  }
  
  // MARK: - Placeholder
  
  private func set(placeholder: String?) {
    let attributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: placeholderColor ?? UIColor.softScript,
      .font: UIFont.body(.regular)
    ]
    attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: attributes)
  }
  
  // MARK: - Responder
  
  @discardableResult
  open override func becomeFirstResponder() -> Bool {
    handleResponder(isFirst: true)
    return super.becomeFirstResponder()
  }
  
  @discardableResult
  open override func resignFirstResponder() -> Bool {
    handleResponder(isFirst: false)
    let resigned = super.resignFirstResponder()
    layoutIfNeeded() // Little dirty hack around UITextField bug that glitch when resigning keyboard 💩
    return resigned
  }
  
  func applyBorder() {
    layer.borderColor = tintColor.cgColor
    layer.borderWidth = InputConstraints.border
  }
  
  func removeBorder() {
    layer.borderColor = UIColor.clear.cgColor
    layer.borderWidth = 0
  }
  
  private func handleResponder(isFirst: Bool) {
    guard isFirst else {
      removeBorder(); return
    }
    applyBorder()
  }
  
  // MARK: - Custom placeholder padding
  
  open override func textRect(forBounds bounds: CGRect) -> CGRect {
    let extraPaddingForX =
      clearButtonMode != .never ? InputConstraints.xPadding * 2 : 0
    
    return CGRect(x: bounds.origin.x + InputConstraints.xPadding,
                  y: bounds.origin.y + InputConstraints.yPadding,
                  width: bounds.size.width - InputConstraints.xPadding - extraPaddingForX,
                  height: bounds.size.height - InputConstraints.yPadding * 2)
  }
  
  open override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return textRect(forBounds: bounds)
  }
}
