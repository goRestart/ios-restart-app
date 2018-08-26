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
    return textView
  }()

  private let bag = DisposeBag()
  
  override func setupView() {
    addSubview(titleView)
    addSubview(textView)
    textView.becomeFirstResponder()
  }

  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return textView.becomeFirstResponder()
  }
  
  override func setupConstraints() {
    titleView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
    }

    Keyboard.subscribe(to: [.willShow]).subscribe(onNext: { [titleView, textView] keyboard in
      textView.snp.remakeConstraints ({ make in
        make.leading.equalTo(self).offset(Margin.medium)
        make.top.equalTo(titleView.snp.bottom).offset(Margin.medium)
        make.trailing.equalTo(self).offset(-Margin.medium)
        make.bottom.equalTo(-keyboard.endFrame.height - Margin.medium)
      })
    }).disposed(by: bag)
  }
}

// MARK: - View bindings

extension Reactive where Base: ProductDescriptionView {
  var productDescription: ControlProperty<String> {
    return base.textView.rx.value.orEmpty
  }
}
