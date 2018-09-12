import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize texts

final class P2PPaymentsOfferFeesSellerView: UIView {
    private let grossTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.text = "Buyer pay"
        return label
    }()

    fileprivate let feeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.text = "Payment fee"
        return label
    }()

    private let netTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .p2pPaymentsPositive
        label.font = UIFont.systemBoldFont(size: 20)
        label.text = "You receive"
        return label
    }()

    fileprivate let grossLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        return label
    }()

    fileprivate let feeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        return label
    }()

    fileprivate let netLabel: UILabel = {
        let label = UILabel()
        label.textColor = .p2pPaymentsPositive
        label.font = UIFont.systemBoldFont(size: 20)
        return label
    }()

    fileprivate let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Info", for: .normal)
        button.isHidden = true
        return button
    }()

    private lazy var titlesStackView: UIStackView = {
        let stackView = UIStackView.vertical([grossTitleLabel, feeTitleLabel, netTitleLabel])
        stackView.alignment = .leading
        stackView.spacing = 16
        return stackView
    }()

    private lazy var amountsStackView: UIStackView = {
        let stackView = UIStackView.vertical([grossLabel, feeLabel, netLabel])
        stackView.alignment = .trailing
        stackView.spacing = 16
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([titlesStackView, amountsStackView])
        NSLayoutConstraint.activate([
            titlesStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titlesStackView.topAnchor.constraint(equalTo: topAnchor),
            titlesStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            amountsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            amountsStackView.topAnchor.constraint(equalTo: topAnchor),
            amountsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsOfferFeesSellerView {
    var grossText: Binder<String?> { return base.grossLabel.rx.text }
    var feeText: Binder<String?> { return base.feeLabel.rx.text }
    var netText: Binder<String?> { return base.netLabel.rx.text }
    var infoButtonTap: ControlEvent<Void> { return base.infoButton.rx.tap }

    var feePercentageText: Binder<String?> {
        return Binder(base) { base, string in
            let percentageText: String = {
                guard let string = string else { return "" }
                return " (\(string))"
            }()
            base.feeTitleLabel.text = "Payment fee " + percentageText
        }
    }
}
