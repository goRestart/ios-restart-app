import UIKit
import LGComponents

// TODO: @juolgon Localize texts

final class P2PPaymentsChangeOfferView: UIView {
    private enum Layout {
        static let currencyTextFieldTopMargin: CGFloat = 25
        static let doneButtonHorizontalMargin: CGFloat = 24
        static let doneButtonBottomMargin: CGFloat = 12
        static let doneButtonHeight: CGFloat = 55
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .grayRegular
        label.font = UIFont.systemFont(size: 18)
        label.text = "Seller receives"
        return label
    }()

    private let currencyTextField = P2PPaymentsCurrencyTextField()

    fileprivate let doneButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle("Set new offer", for: .normal)
        return button
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([titleLabel, currencyTextField, doneButton])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            currencyTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.currencyTextFieldTopMargin),
            currencyTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            currencyTextField.trailingAnchor.constraint(equalTo: trailingAnchor),

            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.doneButtonHorizontalMargin),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.doneButtonHorizontalMargin),
            doneButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.doneButtonBottomMargin),
            doneButton.heightAnchor.constraint(equalToConstant: Layout.doneButtonHeight),
        ])
    }
}
