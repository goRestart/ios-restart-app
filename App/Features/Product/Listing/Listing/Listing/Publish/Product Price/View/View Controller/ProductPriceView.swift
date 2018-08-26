import UI
import RxSwift
import RxCocoa

final class ProductPriceView: View {
  private let titleView: TitleView = {
    let titleView = TitleView()
    titleView.title = Localize("product_price.title", table: Table.productPrice)
    return titleView
  }()
  
  fileprivate var inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Localize("product_price.price.input.placeholder", table: Table.productPrice)
    textField.font = .h2
    textField.textColor = .darkScript
    textField.keyboardType = .decimalPad
    return textField
  }()
  
  fileprivate let nextButton: FullWidthButton = {
    let button = FullWidthButton()
    button.radiusDisabled = true
    let title = Localize("product_price.next_button.title", Table.productPrice).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()

  private let bag = DisposeBag()
  
  override func setupView() {
    addSubview(titleView)
    addSubview(inputTextField)
    addSubview(nextButton)
    inputTextField.becomeFirstResponder()
  }

  override func setupConstraints() {
    titleView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
    }
    
    Keyboard.subscribe(to: [.willShow]).subscribe(onNext: { [titleView, inputTextField, nextButton] keyboard in
      nextButton.snp.remakeConstraints { make in
        make.leading.equalTo(self)
        make.trailing.equalTo(self)
        make.bottom.equalTo(-keyboard.endFrame.height)
      }
      
      inputTextField.snp.remakeConstraints { make in
        make.leading.equalTo(self).offset(Margin.medium)
        make.top.equalTo(titleView.snp.bottom).offset(Margin.medium)
        make.trailing.equalTo(self).offset(-Margin.medium)
      }
    }).disposed(by: bag)
  }
  
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return inputTextField.becomeFirstResponder()
  }
}

// MARK: - View bindings

extension Reactive where Base: ProductPriceView {
  var productPrice: ControlProperty<String> {
    return base.inputTextField.rx.value.orEmpty
  }
  
  var nextButtonWasTapped: Observable<Void> {
    return base.nextButton.rx.buttonWasTapped
  }
  
  var nextButtonIsEnabled: Binder<Bool> {
    return base.nextButton.rx.isEnabled
  }
}
