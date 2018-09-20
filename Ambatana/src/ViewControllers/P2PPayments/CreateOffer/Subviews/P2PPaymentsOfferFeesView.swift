import UIKit
import LGComponents
import RxSwift
import RxCocoa


final class P2PPaymentsOfferFeesView: UIView {
    private enum Layout {
    }

    private let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.text = R.Strings.paymentsCreateOfferSellerPriceLabel
        return label
    }()

    fileprivate let feeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.text = R.Strings.paymentsCreateOfferFeeLabel
        return label
    }()

    private let totalTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lgBlack
        label.font = UIFont.systemBoldFont(size: 20)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.text = R.Strings.paymentsCreateOfferTotalLabel
        return label
    }()

    fileprivate let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    fileprivate let feeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    fileprivate let totalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lgBlack
        label.font = UIFont.systemBoldFont(size: 24)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    fileprivate let changeButton: LetgoButton = {
        let button = LetgoButton(withStyle: ButtonStyle.pinkish(fontSize: .small, withBorder: false))
        button.setTitle(R.Strings.paymentsCreateOfferChangeButton, for: .normal)
        return button
    }()

    fileprivate let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(R.Strings.paymentsCreateOfferInfoButton, for: .normal)
        button.isHidden = true
        return button
    }()

    private lazy var titlesStackView: UIStackView = {
        let stackView = UIStackView.vertical([priceTitleLabel, feeTitleLabel, totalTitleLabel])
        stackView.alignment = .leading
        stackView.spacing = 12
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stackView
    }()

    private lazy var amountsStackView: UIStackView = {
        let stackView = UIStackView.vertical([priceLabel, feeLabel, totalLabel])
        stackView.alignment = .leading
        stackView.spacing = 12
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.horizontal([titlesStackView, amountsStackView, changeButton])
        stackView.distribution = .fill
        stackView.alignment = .lastBaseline
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([stackView, infoButton])
        stackView.constraintToEdges(in: self)
        NSLayoutConstraint.activate([
            totalTitleLabel.heightAnchor.constraint(equalTo: totalLabel.heightAnchor),
            infoButton.leadingAnchor.constraint(equalTo: feeLabel.trailingAnchor, constant: 4),
            infoButton.centerYAnchor.constraint(equalTo: feeLabel.centerYAnchor),
        ])
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsOfferFeesView {
    var priceText: Binder<String?> {
        return base.priceLabel.rx.text
    }

    var feeText: Binder<String?> {
        return base.feeLabel.rx.text
    }

    var totalText: Binder<String?> {
        return base.totalLabel.rx.text
    }

    var feePercentageText: Binder<String?> {
        return Binder(base) { base, string in
            base.feeTitleLabel.text = R.Strings.paymentsCreateOfferFeePercentageLabel(string ?? "")
        }
    }

    var infoButtonTap: ControlEvent<Void> {
        return base.infoButton.rx.tap
    }

    var changeButtonTap: ControlEvent<Void> {
        return base.changeButton.rx.tap
    }
}
