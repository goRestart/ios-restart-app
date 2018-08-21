import UI

final class ProductPriceView: View {

  var inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Localize("product_price.price.input.placeholder", table: Table.productPrice)
    textField.font = .h2
    textField.textColor = .darkScript
    textField.keyboardType = .decimalPad
    return textField
  }()

  override func setupView() {
    addSubview(inputTextField)
    inputTextField.becomeFirstResponder()
  }

  override func setupConstraints() {
    inputTextField.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
    }
  }
}
