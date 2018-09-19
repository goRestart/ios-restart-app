import LGComponents

private enum Layout {
    enum Size {
        static let brand = CGSize(width: 55, height: 55)
        static let redeemButton = CGSize(width: UIViewNoIntrinsicMetric, height: 50)
    }
}

final class AffiliationStoreCell: UICollectionViewCell, ReusableCell {

    private let background: UIImageView = {
        let background = UIImageView()
        background.contentMode = .scaleAspectFill
        background.image = R.Asset.BackgroundsAndImages.affStoreBackground.image
        return background
    }()

    private let partnerImageView: UIImageView = {
        let brand = UIImageView()
        brand.contentMode = .scaleAspectFit
        brand.backgroundColor = .red
        brand.cornerRadius = Layout.Size.brand.width / 2
        return brand
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemBoldFont(size: 14)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemBoldFont(size: 28)
        label.textColor = .lgBlack
        return label
    }()

    let redeemButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.affiliationStoreRedeemGift, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupUI() {
        backgroundColor = .clear
        addSubviewsForAutoLayout([background, partnerImageView, pointsLabel, titleLabel, redeemButton])

        background.constraintsToEdges(in: contentView).activate()
        [
            partnerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            partnerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin),
            partnerImageView.heightAnchor.constraint(equalToConstant: Layout.Size.brand.height),
            partnerImageView.heightAnchor.constraint(equalTo: partnerImageView.widthAnchor),

            pointsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            pointsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),

            titleLabel.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: Metrics.veryBigMargin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            titleLabel.trailingAnchor.constraint(equalTo: partnerImageView.leadingAnchor),

            redeemButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.margin),
            redeemButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            redeemButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin),
            redeemButton.heightAnchor.constraint(equalToConstant: Layout.Size.redeemButton.height)
        ].activate()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        applyShadow(withOpacity: 0.15, radius: Metrics.margin)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: Metrics.margin).cgPath
    }

    func populate(with data: AffiliationPurchase) {
        titleLabel.text = data.title
        pointsLabel.text = data.points
        partnerImageView.image = data.partnerIcon

        redeemButton.isEnabled = data.state == .enabled
    }
}
