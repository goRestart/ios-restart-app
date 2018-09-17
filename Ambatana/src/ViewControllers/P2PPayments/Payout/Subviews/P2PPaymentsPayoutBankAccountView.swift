import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsPayoutBankAccountView: UIView {
    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 24
        static let buttonHeight: CGFloat = 55
        static let buttonBottomMargin: CGFloat = 16
    }

    private let routingNumberTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Routing number (9 digits)")
        textField.returnKeyType = .next
        return textField
    }()

    private let accountNumberTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Account number")
        textField.returnKeyType = .done
        return textField
    }()

    private let paymentSelector: P2PPaymentsPayoutPaymentSelectorView = {
        let selector = P2PPaymentsPayoutPaymentSelectorView()
        selector.state = P2PPaymentsPayoutPaymentSelectorState(kind: .standard,
                                                               isSelected: true,
                                                               feeText: nil,
                                                               fundsAvailableText: nil)
        return selector
    }()

    private let actionButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle("Payout", for: .normal)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private var bottomContraint: NSLayoutConstraint?
    private let keyboardHelper = KeyboardHelper()
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        configureTextFields()
        configureStackView()
        scrollView.addSubviewsForAutoLayout([stackView, paymentSelector, actionButton])
        addSubviewForAutoLayout(scrollView)
        setupConstraints()
        setupRx()
    }

    private func configureStackView() {
        stackView.addArrangedSubviews([
            routingNumberTextField,
            accountNumberTextField,
        ])
    }

    private func configureTextFields() {
        routingNumberTextField.nextResponderTextField = accountNumberTextField
        [routingNumberTextField,
         accountNumberTextField].forEach { textfield in
            textfield.addTarget(self,
                                action: #selector(textFieldDidBeginEditing(textField:)),
                                for: UIControlEvents.editingDidBegin)
        }
    }

    private func setupConstraints() {
        bottomContraint = scrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        bottomContraint?.isActive = true
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            paymentSelector.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
            paymentSelector.widthAnchor.constraint(equalTo: widthAnchor, constant: -32),

            actionButton.heightAnchor.constraint(equalToConstant: 55),
            actionButton.widthAnchor.constraint(equalTo: widthAnchor),
            actionButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: paymentSelector.bottomAnchor),
            actionButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }

    private func setupRx() {
        Driver
            .combineLatest([
                routingNumberTextField.rx.isEmpty,
                accountNumberTextField.rx.isEmpty,
            ])
            .map { !$0.contains(true) }
            .drive(actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    @objc private func textFieldDidBeginEditing(textField: UITextField) {
        let adjustedFrame = textField.frame.insetBy(dx: 0, dy: -50)
        scrollView.scrollRectToVisible(adjustedFrame, animated: true)
    }

    func setupKeyboardHelper() {
        keyboardHelper
            .rx_keyboardHeight
            .asDriver()
            .skip(1)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] height in
                self?.bottomContraint?.constant = -height
                self?.layoutIfNeeded()
            }).disposed(by: disposeBag)
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsPayoutBankAccountView {
}
