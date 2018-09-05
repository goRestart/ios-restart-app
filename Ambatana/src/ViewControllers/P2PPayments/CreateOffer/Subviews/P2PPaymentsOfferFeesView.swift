import UIKit
import LGComponents

// TODO: @juolgon Localize texts

final class P2PPaymentsOfferFeesView: UIView {
    private enum Layout {
    }

    private let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.text = "Seller receives"
        return label
    }()

    private let feeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.text = "Payment fee 2%"
        return label
    }()

    private let totalTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lgBlack
        label.font = UIFont.systemBoldFont(size: 20)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.text = "You pay"
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.text = "$930"
        return label
    }()

    private let feeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayRegular
        label.font = UIFont.systemMediumFont(size: 18)
        label.text = "$930"
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lgBlack
        label.font = UIFont.systemBoldFont(size: 24)
        label.text = "$930"
        return label
    }()

    private let changeButton: LetgoButton = {
        let button = LetgoButton(withStyle: ButtonStyle.pinkish(fontSize: .small, withBorder: false))
        button.setTitle("Change", for: .normal)
        return button
    }()

    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Info", for: .normal)
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
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.horizontal([titlesStackView, amountsStackView, changeButton])
        stackView.distribution = .fillProportionally
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
