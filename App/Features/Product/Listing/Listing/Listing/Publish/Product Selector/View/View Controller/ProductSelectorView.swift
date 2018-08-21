import UI
import Search
import SnapKit
import Core
import Domain

protocol ProductSelectorViewDelegate: class {
  func onGameSelected(with id: Identifier<Game>)
}

final class ProductSelectorView: View {

  weak var delegate: ProductSelectorViewDelegate?

  private var inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Localize("product_selector.search.input.placeholder", table: Table.productSelector)
    textField.font = .h2
    textField.textColor = .darkScript
    return textField
  }()

  private var searchView: SearchView = {
    return resolver.searchView
  }()

  override func setupView() {
    addSubview(inputTextField)
    addSubview(searchView)

    inputTextField.becomeFirstResponder()
    searchView.bind(textField: inputTextField) { [weak self] selectedGameId in
      self?.delegate?.onGameSelected(with: selectedGameId)
    }
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
