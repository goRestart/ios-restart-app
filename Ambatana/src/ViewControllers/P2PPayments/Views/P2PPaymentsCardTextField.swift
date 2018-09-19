import UIKit
import LGComponents
import RxSwift
import RxCocoa
import Stripe

// TODO: @juolgon localize texts

final class P2PPaymentsCardTextField: STPPaymentCardTextField {
    private let lineView = P2PPaymentsLineSeparatorView()
    fileprivate let isValidRelay = BehaviorRelay<Bool>(value: false)

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        font = UIFont.boldSystemFont(ofSize: 20)
        textColor = .lgBlack
        textErrorColor = .primaryColor
        placeholderColor = .grayRegular
        numberPlaceholder = "Card number"
        borderColor = nil
        tintColor = .primaryColor
        addSubviewForAutoLayout(lineView)
        delegate = self
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: 48)
    }
}

extension P2PPaymentsCardTextField: STPPaymentCardTextFieldDelegate {
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        isValidRelay.accept(textField.isValid)
    }
}

extension Reactive where Base: P2PPaymentsCardTextField {
    var isValid: Driver<Bool> {
        return base.isValidRelay.asDriver()
    }
}
