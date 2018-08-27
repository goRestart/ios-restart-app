import UIKit
import LGComponents

// TODO: @juolgon Localize texts

final class P2PPaymentsCreateOfferBuyerInfoView: UIView {
    private enum Layout {
        static let buyerProtectionTopMargin: CGFloat = 36
    }

    private let escrowInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .grayDark
        label.numberOfLines = 0
        label.font = UIFont.systemFont(size: 14)
        label.text = "We'll hold the funds in escrow and won't release the payment to the seller until you receive the item"
        return label
    }()

    private let buyerProtectionView = BuyerProtectionView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([escrowInfoLabel, buyerProtectionView])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            escrowInfoLabel.topAnchor.constraint(equalTo: topAnchor),
            escrowInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            escrowInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            buyerProtectionView.topAnchor.constraint(equalTo: escrowInfoLabel.bottomAnchor, constant: Layout.buyerProtectionTopMargin),
            buyerProtectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buyerProtectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buyerProtectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - BuyerProtectionView

private extension P2PPaymentsCreateOfferBuyerInfoView {
    final class BuyerProtectionView: UIView {
        private enum Layout {
            static let iconSize: CGFloat = 34
            static let iconTopMargin: CGFloat = 12
            static let iconLeadingMargin: CGFloat = 8
            static let intertextMargin: CGFloat = 4
            static let textLeadingMargin: CGFloat = 8
            static let textTrailingMargin: CGFloat = 12
            static let textBottomMargin: CGFloat = 12
        }

        let iconImageView: UIImageView = {
            let imageView = UIImageView(image: R.Asset.P2PPayments.icTrust.image)
            imageView.tintColor = .p2pPaymentsPositive
            return imageView
        }()

        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemBoldFont(size: 18)
            label.text = "Buyer Protection"
            label.textColor = .p2pPaymentsPositive
            return label
        }()

        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.textColor = .grayDark
            label.font = UIFont.systemFont(size: 16)
            label.numberOfLines = 0
            label.text = "Pay through letgo and your funds will only be transferred to the seller when you confirm you want to keep the item"
            return label
        }()

        init() {
            super.init(frame: .zero)
            setup()
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        private func setup() {
            backgroundColor = .veryLightGray
            cornerRadius = 13
            addSubviewsForAutoLayout([iconImageView, titleLabel, descriptionLabel])
            setupConstraints()
        }

        private func setupConstraints() {
            NSLayoutConstraint.activate([
                iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),
                iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
                iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.iconLeadingMargin),
                iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.iconTopMargin),

                titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Layout.textLeadingMargin),

                descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.textTrailingMargin),
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.intertextMargin),
                descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.textBottomMargin)
            ])
        }
    }
}
