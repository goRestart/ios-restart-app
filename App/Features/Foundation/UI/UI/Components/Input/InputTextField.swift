import Foundation

private struct InputTextFieldConstraints {
  static let inputHeight = 48
}

open class InputTextField: UIView {
  
  // MARK: - Public
  
  public enum State {
    case normal
    case errored
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  
  private var erroredInput: String?
  public var error: String? {
    didSet {
      guard let error = error else {
        errorLabel.text = nil
        set(state: .normal)
        return
      }
      errorLabel.text = error
      set(state: .errored)
    }
  }
  
  // MARK: - Private
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .body(.semibold)
    label.textColor = .darkScript
    return label
  }()

  private lazy var errorLabel: UILabel = {
    let label = UILabel()
    label.font = .tiny
    label.textColor = .danger
    return label
  }()
  
  public lazy var input: Input = {
    let input = Input()
    input.clearButtonMode = .whileEditing
    input.backgroundColor = .clear
    input.delegate = self
    return input
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Margin.smallest
    return stackView
  }()
  
  public var state: State? {
    didSet {
      set(state: state!)
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
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(input)
    stackView.addArrangedSubview(errorLabel)
    addSubview(stackView)
    set(state: .normal)
    applyConstraints()
  }
  
  // MARK: - State
  
  private func set(state: State) {
    switch state {
    case .normal:
      input.backgroundColor = .softGrey
      input.tintColor = .primary
      input.textColor = .primary
      input.removeBorder()
    case .errored:
      input.backgroundColor = UIColor.danger.withAlphaComponent(0.1)
      input.tintColor = .danger
      input.textColor = .danger
      input.applyBorder()
      erroredInput = input.text
    }
    input.setNeedsDisplay()
    input.setNeedsLayout()
  }
  
  // MARK: - Responder
  
  @discardableResult
  open override func becomeFirstResponder() -> Bool {
    return input.becomeFirstResponder()
  }
  
  @discardableResult
  open override func resignFirstResponder() -> Bool {
    return input.resignFirstResponder()
  }
  
  // MARK: - Layout
  
  private func applyConstraints() {
    stackView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
    input.snp.makeConstraints { make in
      make.height.equalTo(InputTextFieldConstraints.inputHeight)
    }
  }
}

// MARK: - UITextFieldDelegate

extension InputTextField: UITextFieldDelegate {
  public func textFieldDidEndEditing(_ textField: UITextField) {
    let erroredInputHasBeenUpdated = erroredInput != input.text
    guard erroredInputHasBeenUpdated else { return }
    error = nil
  }
}
