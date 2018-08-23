import UI
import Search
import SnapKit
import Core
import RxSwift

final class ProductSelectorView: View {
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
    addSubview(inputTextField)
    addSubview(searchView)

    inputTextField.becomeFirstResponder()
    
    searchView.bind(rx.query)
  }

  override func setupConstraints() {
    inputTextField.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
    }

    searchView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(inputTextField.snp.bottom).offset(Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
    }
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
