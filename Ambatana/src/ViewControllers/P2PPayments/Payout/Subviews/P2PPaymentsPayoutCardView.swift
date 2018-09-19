import UIKit
import LGComponents
import RxSwift
import RxCocoa
import Stripe

// TODO: @juolgon Localize all texts

final class P2PPaymentsPayoutCardView: UIView {
    private let nameTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Name on card")
        textField.returnKeyType = .next
        return textField
    }()

    private let cardTextField = P2PPaymentsCardTextField()

    private let paymentTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 14)
        label.textColor = .lgBlack
        label.text = "Choose one of these options:"
        return label
    }()

    private let standardPaymentSelector: P2PPaymentsPayoutPaymentSelectorView = {
        let selector = P2PPaymentsPayoutPaymentSelectorView()
        selector.state = P2PPaymentsPayoutPaymentSelectorState(kind: .standard,
                                                               isSelected: true,
                                                               feeText: nil,
                                                               fundsAvailableText: nil)
        return selector
    }()

    private let instantPaymentSelector: P2PPaymentsPayoutPaymentSelectorView = {
        let selector = P2PPaymentsPayoutPaymentSelectorView()
        selector.state = P2PPaymentsPayoutPaymentSelectorState(kind: .standard,
                                                               isSelected: true,
                                                               feeText: nil,
                                                               fundsAvailableText: nil)
        return selector
    }()

    let actionButton: UIButton = {
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
        scrollView.addSubviewsForAutoLayout([stackView,
                                             standardPaymentSelector,
                                             instantPaymentSelector,
                                             actionButton])
        addSubviewForAutoLayout(scrollView)
        setupConstraints()
        setupRx()
    }

    private func configureStackView() {
        stackView.addArrangedSubviews([
            nameTextField,
            cardTextField,
        ])
    }

    private func configureTextFields() {
        nameTextField.nextResponderTextField = cardTextField
        [nameTextField, cardTextField].forEach { textfield in
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

            standardPaymentSelector.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
            standardPaymentSelector.widthAnchor.constraint(equalTo: widthAnchor, constant: -32),

            actionButton.heightAnchor.constraint(equalToConstant: 55),
            actionButton.widthAnchor.constraint(equalTo: widthAnchor),
            actionButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: standardPaymentSelector.bottomAnchor),
            actionButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }

    private func setupRx() {
        Driver
            .combineLatest([
                nameTextField.rx.isEmpty,
                cardTextField.rx.isValid.map { !$0 },
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

extension Reactive where Base: P2PPaymentsPayoutCardView {
}
