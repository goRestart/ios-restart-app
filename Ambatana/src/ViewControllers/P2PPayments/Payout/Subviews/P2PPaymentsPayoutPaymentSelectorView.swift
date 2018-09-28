import UIKit
import LGComponents
import RxSwift
import RxCocoa


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
        case .standard: return R.Strings.paymentPayoutPaymentTypeStandar
        case .instant: return R.Strings.paymentPayoutPaymentTypeInstant
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

    private enum Layout {
        static let height: CGFloat = 114
        static let cornerRadius: CGFloat = 12
        static let paymentTypeTopMargin: CGFloat = 16
        static let paymentTypeLeadingMargin: CGFloat = 16
        static let titleTopMargin: CGFloat = 4
        static let checkboxSize: CGFloat = 24
        static let checkboxTrailingMargin: CGFloat = 16
    }

    private let paymentTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 20)
        label.textColor = UIColor.lgBlack
        label.text = R.Strings.paymentPayoutPaymentTypeStandar
        return label
    }()

    private let freeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 16)
        label.textColor = UIColor.primaryColor
        label.text = R.Strings.paymentPayoutPaymentStandarTitleLabel
        return label
    }()

    private let freeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 16)
        label.textColor = UIColor.grayDark
        label.text = R.Strings.paymentPayoutPaymentStandarSubtitleLabel
        return label
    }()

    private let instantTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 16)
        label.textColor = UIColor.grayDark
        label.text = R.Strings.paymentPayoutPaymentInstantTitleLabel
        return label
    }()

    private let instantSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 16)
        label.textColor = UIColor.primaryColor
        label.text = R.Strings.paymentPayoutPaymentInstantSubtitleLabel
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
        cornerRadius = Layout.cornerRadius
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
            paymentTypeLabel.topAnchor.constraint(equalTo: topAnchor, constant: Layout.paymentTypeTopMargin),
            paymentTypeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.paymentTypeLeadingMargin),

            freeTitleLabel.topAnchor.constraint(equalTo: paymentTypeLabel.bottomAnchor, constant: Layout.titleTopMargin),
            freeTitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            freeSubtitleLabel.topAnchor.constraint(equalTo: freeTitleLabel.bottomAnchor, constant: Layout.titleTopMargin),
            freeSubtitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            instantTitleLabel.topAnchor.constraint(equalTo: paymentTypeLabel.bottomAnchor, constant: Layout.titleTopMargin),
            instantTitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            instantSubtitleLabel.topAnchor.constraint(equalTo: instantTitleLabel.bottomAnchor, constant: Layout.titleTopMargin),
            instantSubtitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            checkboxView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkboxView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.checkboxTrailingMargin),
            checkboxView.widthAnchor.constraint(equalToConstant: Layout.checkboxSize),
            checkboxView.heightAnchor.constraint(equalToConstant: Layout.checkboxSize),
        ])
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: Layout.height)
    }

    private func configureForCurrentState() {
        paymentTypeLabel.text = state.paymentTypeText
        checkboxView.update(withState: isSelected ? .selected : .deselected)
        freeTitleLabel.isHidden = state.kind != .standard
        freeSubtitleLabel.isHidden = state.kind != .standard
        instantTitleLabel.isHidden = state.kind != .instant
        instantSubtitleLabel.isHidden = state.kind != .instant
        instantTitleLabel.text = R.Strings.paymentPayoutPaymentFee(state.feeText ?? "")
        freeSubtitleLabel.text = R.Strings.paymentPayoutPaymentAvailability(state.fundsAvailableText ?? "")
        instantSubtitleLabel.text = R.Strings.paymentPayoutPaymentAvailability(state.fundsAvailableText ?? "")
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
