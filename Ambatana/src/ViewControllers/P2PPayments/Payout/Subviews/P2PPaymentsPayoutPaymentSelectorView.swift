import UIKit
import LGComponents

// TODO: @juolgon localize all texts

final class P2PPaymentsPayoutPaymentSelectorView: UIView {
    private let paymentTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 20)
        label.textColor = UIColor.lgBlack
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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = UIColor.white
        cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayRegular.cgColor
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

            freeSubtitleLabel.topAnchor.constraint(equalTo: freeTitleLabel.bottomAnchor, constant: 2),
            freeSubtitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            instantTitleLabel.topAnchor.constraint(equalTo: paymentTypeLabel.bottomAnchor, constant: 4),
            instantTitleLabel.leadingAnchor.constraint(equalTo: paymentTypeLabel.leadingAnchor),

            instantSubtitleLabel.topAnchor.constraint(equalTo: instantTitleLabel.bottomAnchor, constant: 2),
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
}
