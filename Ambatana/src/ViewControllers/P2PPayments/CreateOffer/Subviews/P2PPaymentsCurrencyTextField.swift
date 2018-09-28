import UIKit
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

final class P2PPaymentsCurrencyTextField: UIView, UITextFieldDelegate {
    fileprivate static let valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    var value: Decimal = Decimal(0)
    var currencyCode: String? = Locale.autoupdatingCurrent.currencyCode

    private let formattedTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lgBlack
        label.font = .systemBoldFont(size: 36)
        return label
    }()

    fileprivate let hiddenTextField: UITextField = {
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
        addSubview(hiddenTextField)
        addSubviewForAutoLayout(formattedTextLabel)
        hiddenTextField.delegate = self
        hiddenTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
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
        hiddenTextField.becomeFirstResponder()
    }

    @objc private func editingChanged() {
        let newValue = Decimal(string: hiddenTextField.text ?? "0", locale: Locale.current) ?? 0
        value = newValue
        updateFormattedLabel()
    }

    fileprivate func updateFormattedLabel() {
        let formattedAmount = Core.currencyHelper.formattedAmountWithCurrencyCode(currencyCode ?? "EUR", amount: (value as NSDecimalNumber).doubleValue)
        formattedTextLabel.text = formattedAmount
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: true)
    }
}

extension Reactive where Base: P2PPaymentsCurrencyTextField {
    var isFocused: Binder<Bool> {
        return Binder<Bool>(self.base) { base, focused in
            if focused {
                base.hiddenTextField.becomeFirstResponder()
            } else {
                base.hiddenTextField.resignFirstResponder()
            }
        }
    }

    var value: Binder<Decimal> {
        return Binder<Decimal>(self.base) { base, value in
            base.value = value
            base.hiddenTextField.text = P2PPaymentsCurrencyTextField.valueFormatter.string(from: value as NSDecimalNumber)
            base.updateFormattedLabel()
        }
    }

    var currencyCode: Binder<String?> {
        return Binder<String?>(self.base) { base, code in
            base.currencyCode = code
            base.updateFormattedLabel()
        }
    }
}
