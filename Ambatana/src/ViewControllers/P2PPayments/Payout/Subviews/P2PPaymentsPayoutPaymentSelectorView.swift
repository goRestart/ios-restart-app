import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon localize all texts

struct P2PPaymentsPayoutPaymentSelectorState {
    enum Kind {
        case standard
        case instant
    }

    let kind: Kind
    var feeText: String?
    var fundsAvailableText: String?

    static let empty = P2PPaymentsPayoutPaymentSelectorState(kind: .standard,
                                                             feeText: nil,
                                                             fundsAvailableText: nil)

    fileprivate var paymentTypeText: String {
        switch kind {
        case .standard: return "Standard payment"
        case .instant: return "Instant payment"
        }
    }
}

final class P2PPaymentsPayoutPaymentSelectorView: UIView {
    var state: P2PPaymentsPayoutPaymentSelectorState = .empty {
        didSet { configureForCurrentState() }
    }

    var isSelected: Bool = false {
        didSet { configureForCurrentState() }
    }

    private let paymentTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 20)
        label.textColor = UIColor.lgBlack
        label.text = "Standard payment"
        return label
    }()

    private let freeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 16)
        label.textColor = UIColor.primaryColor
        label.text = "FREE"
        return label
    }()

    private let freeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 16)
        label.textColor = UIColor.grayDark
        label.text = "Get the money in 3-7 days"
        return label
    }()

    private let instantTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 16)
        label.textColor = UIColor.grayDark
        label.text = "Transaction fee"
        return label
    }()

    private let instantSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 16)
        label.textColor = UIColor.primaryColor
        label.text = "Get the money in under 1 hour"
        return label
    }()

    private let checkboxView = LGCheckboxView(withFrame: .zero, state: .deselected)

    init() {
        super.init(frame: .zero)
        setup()
        configureForCurrentState()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        cornerRadius = 12
        layer.borderWidth = 1
        addSubviewsForAutoLayout([
            paymentTypeLabel,
            freeTitleLabel,
            freeSubtitleLabel,
            instantTitleLabel,
            instantSubtitleLabel,
            checkboxView
        ])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            paymentTypeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            paymentTypeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            freeTitleLabel.topAnchor.constraint(equalTo: paymentTypeLabel.bottomAnchor, constant: 4),
            freeTitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            freeSubtitleLabel.topAnchor.constraint(equalTo: freeTitleLabel.bottomAnchor, constant: 4),
            freeSubtitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            instantTitleLabel.topAnchor.constraint(equalTo: paymentTypeLabel.bottomAnchor, constant: 4),
            instantTitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            instantSubtitleLabel.topAnchor.constraint(equalTo: instantTitleLabel.bottomAnchor, constant: 4),
            instantSubtitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            checkboxView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkboxView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            checkboxView.widthAnchor.constraint(equalToConstant: 24),
            checkboxView.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 114)
    }

    private func configureForCurrentState() {
        paymentTypeLabel.text = state.paymentTypeText
        checkboxView.update(withState: isSelected ? .selected : .deselected)
        freeTitleLabel.isHidden = state.kind != .standard
        freeSubtitleLabel.isHidden = state.kind != .standard
        instantTitleLabel.isHidden = state.kind != .instant
        instantSubtitleLabel.isHidden = state.kind != .instant
        instantTitleLabel.text = "Transaction fee \(state.feeText ?? "")"
        freeSubtitleLabel.text = "Get the money in \(state.fundsAvailableText ?? "")"
        instantSubtitleLabel.text = "Get the money in \(state.fundsAvailableText ?? "")"
        backgroundColor = isSelected ? UIColor.veryLightGray : UIColor.white
        layer.borderColor = isSelected ? UIColor.primaryColor.cgColor : UIColor.grayRegular.cgColor
    }
}

extension Reactive where Base: P2PPaymentsPayoutPaymentSelectorView {
    var feeText: Binder<String?> {
        return Binder(base) { selector, text in
            selector.state.feeText = text
        }
    }

    var fundsAvailableText: Binder<String?> {
        return Binder(base) { selector, text in
            selector.state.fundsAvailableText = text
        }
    }
}
