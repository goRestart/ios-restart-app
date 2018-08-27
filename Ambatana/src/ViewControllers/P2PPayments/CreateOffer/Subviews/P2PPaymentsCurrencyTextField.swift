import UIKit
import LGComponents
import LGCoreKit

final class P2PPaymentsCurrencyTextField: UIView, UITextFieldDelegate {
    var value: Decimal = Decimal(0)

    private let formattedTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lgBlack
        label.font = .systemBoldFont(size: 36)
        return label
    }()

    private let innerTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.isHidden = true
        return textField
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        addSubview(innerTextField)
        addSubviewForAutoLayout(formattedTextLabel)
        innerTextField.delegate = self
        innerTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        editingChanged()
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            formattedTextLabel.topAnchor.constraint(equalTo: topAnchor),
            formattedTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            formattedTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            formattedTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @objc private func tapped() {
        innerTextField.becomeFirstResponder()
    }

    @objc private func editingChanged() {
        let newValue = Decimal(string: innerTextField.text ?? "0", locale: Locale.current) ?? 0
        value = newValue
        let formattedAmount = Core.currencyHelper.formattedAmountWithCurrencyCode("EUR", amount: (newValue as NSDecimalNumber).doubleValue)
        formattedTextLabel.text = formattedAmount
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: true)
    }
}
