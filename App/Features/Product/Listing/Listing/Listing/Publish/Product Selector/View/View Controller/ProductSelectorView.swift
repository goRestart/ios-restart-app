import UI
import Search
import SnapKit
import Core
import RxSwift

final class ProductSelectorView: View {
  private let titleView: TitleView = {
    let titleView = TitleView()
    titleView.title = Localize("product_selector.title", table: Table.productSelector)
    return titleView
  }()
  
  fileprivate var inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Localize("product_selector.search.input.placeholder", table: Table.productSelector)
    textField.font = .h2
    textField.textColor = .darkScript
    return textField
  }()

  fileprivate var searchView = resolver.searchView
  private let bag = DisposeBag()
  
  override func setupView() {
    addSubview(titleView)
    addSubview(inputTextField)
    addSubview(searchView)

    inputTextField.becomeFirstResponder()
    
    searchView.bind(rx.query)
  }

  override func setupConstraints() {
    titleView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
    }
    inputTextField.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.top.equalTo(titleView.snp.bottom).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
    }

    Keyboard.subscribe(to: [.willShow]).subscribe(onNext: { [inputTextField, searchView] keyboard in
      searchView.snp.remakeConstraints { make in
        make.leading.equalTo(self)
        make.trailing.equalTo(self)
        make.top.equalTo(inputTextField.snp.bottom).offset(Margin.medium)
        make.bottom.equalTo(-keyboard.endFrame.height)
      }
    }).disposed(by: bag)
  }
  
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return inputTextField.becomeFirstResponder()
  }
}

// MARK: - View bindings

extension Reactive where Base: ProductSelectorView {
  var state: PublishSubject<GameSuggestionEvent> {
    return base.searchView.rx.state
  }
  
  fileprivate var query: Observable<String> {
    return base.inputTextField.rx.value
      .orEmpty
      .distinctUntilChanged()
      .debounce(0.3, scheduler: MainScheduler.instance)
  }
}
