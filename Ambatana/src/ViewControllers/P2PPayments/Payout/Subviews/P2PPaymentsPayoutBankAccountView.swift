import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsPayoutBankAccountView: UIView {
    var bankAccountParams: P2PPaymentsPayoutViewModel.BankAccountPayoutParams {
        return P2PPaymentsPayoutViewModel.BankAccountPayoutParams(routingNumber: routingNumberTextField.text ?? "",
                                                                  accountNumber: accountNumberTextField.text ?? "")
    }

    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 12
        static let buttonHeight: CGFloat = 55
        static let buttonHorizontalMargin: CGFloat = 24
        static let buttonBottomMargin: CGFloat = 12
        static let textFieldVerticalAdjustment: CGFloat = 50
        static let scrollViewTopMargin: CGFloat = 12
        static let stackViewTopMargin: CGFloat = 4
        static let stackViewBottomMargin: CGFloat = 32
    }

    private let routingNumberTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutBankAccountRoutingNumberPlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let accountNumberTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutBankAccountAccountNumberPlaceholder)
        textField.returnKeyType = .done
        return textField
    }()

    fileprivate let standardPaymentSelector: P2PPaymentsPayoutPaymentSelectorView = {
        let selector = P2PPaymentsPayoutPaymentSelectorView()
        selector.state = P2PPaymentsPayoutPaymentSelectorState(kind: .standard,
                                                               feeText: nil,
                                                               fundsAvailableText: nil)
        selector.isSelected = true
        return selector
    }()

    fileprivate let actionButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle(R.Strings.paymentsPayoutBankAccountPayoutButton, for: .normal)
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
        configureScrollView()
        addSubviewsForAutoLayout([scrollView, actionButton])
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
        [routingNumberTextField, accountNumberTextField].forEach { textfield in
            textfield.addTarget(self,
                                action: #selector(textFieldDidBeginEditing(textField:)),
                                for: UIControlEvents.editingDidBegin)
        }
    }

    private func configureScrollView() {
        scrollView.contentInset.bottom = Layout.buttonHeight + Layout.buttonBottomMargin
        scrollView.addSubviewsForAutoLayout([stackView, standardPaymentSelector])
    }

    private func setupConstraints() {
        bottomContraint = scrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        bottomContraint?.isActive = true
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.scrollViewTopMargin),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * Layout.contentHorizontalMargin),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Layout.stackViewTopMargin),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Layout.contentHorizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Layout.contentHorizontalMargin),

            standardPaymentSelector.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Layout.stackViewBottomMargin),
            standardPaymentSelector.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            standardPaymentSelector.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            actionButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.buttonHorizontalMargin),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.buttonHorizontalMargin),
            actionButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Layout.buttonBottomMargin),
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
        let adjustedFrame = textField.frame.insetBy(dx: 0, dy: -Layout.textFieldVerticalAdjustment)
        scrollView.scrollRectToVisible(adjustedFrame, animated: true)
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsPayoutBankAccountView {
    var payoutButtonTap: ControlEvent<Void> {
        return base.actionButton.rx.tap
    }

    var standardFundsAvailableText: Binder<String?> {
        return base.standardPaymentSelector.rx.fundsAvailableText
    }
}
