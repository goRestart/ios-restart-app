import UI
import RxSwift
import RxCocoa

final class ProductDescriptionView: View {
  private let titleView: TitleView = {
    let titleView = TitleView()
    titleView.title = Localize("product_description.title", table: Table.productDescription)
    return titleView
  }()
  
  fileprivate var textView: UITextView = {
    let textView = UITextView()
    textView.font = .h2
    textView.textColor = .darkScript
    textView.autocorrectionType = .no
    return textView
  }()

  fileprivate let nextButton: FullWidthButton = {
    let button = FullWidthButton()
    button.radiusDisabled = true
    let title = Localize("product_description.next_button.title", Table.productDescription).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()
  
  private let bag = DisposeBag()
  
  override func setupView() {
    addSubview(titleView)
    addSubview(textView)
    addSubview(nextButton)
    textView.becomeFirstResponder()
  }

  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return textView.becomeFirstResponder()
  }
  
  @discardableResult
  override func resignFirstResponder() -> Bool {
    return textView.resignFirstResponder()
  }
  
  override func setupConstraints() {
    titleView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
    }

    Keyboard.subscribe(to: [.willShow, .didShow]).subscribe(onNext: { [titleView, textView, nextButton] keyboard in
      nextButton.snp.remakeConstraints { make in
        make.leading.equalTo(self)
        make.trailing.equalTo(self)
        make.bottom.equalTo(-keyboard.endFrame.height)
      }
      
      textView.snp.remakeConstraints { make in
        make.leading.equalTo(self).offset(Margin.medium)
        make.top.equalTo(titleView.snp.bottom).offset(Margin.medium)
        make.trailing.equalTo(self).offset(-Margin.medium)
        make.bottom.equalTo(nextButton.snp.top)
      }
    }).disposed(by: bag)
  }
}

// MARK: - View bindings

extension Reactive where Base: ProductDescriptionView {
  var productDescription: ControlProperty<String> {
    return base.textView.rx.value.orEmpty
  }
  
  var nextButtonWasTapped: Observable<Void> {
    return base.nextButton.rx.buttonWasTapped
  }
  
  var nextButtonIsEnabled: Binder<Bool> {
    return base.nextButton.rx.isEnabled
  }
}
