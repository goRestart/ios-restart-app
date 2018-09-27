import LGComponents
import RxSwift
import RxCocoa

private enum Layout {
    enum Size {
        static let brand = CGSize(width: 55, height: 55)
        static let redeemButton = CGSize(width: UIViewNoIntrinsicMetric, height: 50)
    }
}

final class AffiliationStoreCell: UICollectionViewCell, ReusableCell {
    fileprivate let reused = PublishRelay<Void>()
    let disposeBag = DisposeBag()
    
    private let background: UIImageView = {
        let background = UIImageView()
        background.contentMode = .scaleAspectFill
        return background
    }()

    private let partnerImageView: UIImageView = {
        let brand = UIImageView()
        brand.contentMode = .scaleAspectFit
        brand.backgroundColor = .red
        brand.cornerRadius = Layout.Size.brand.width / 2
        return brand
    }()

    private let pointsView = AffiliationPointsView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemBoldFont(size: 28)
        label.textColor = .lgBlack
        return label
    }()

    fileprivate let redeemButton: LetgoButton = {
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

    override func prepareForReuse() {
        super.prepareForReuse()
        reused.accept(())
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubviewsForAutoLayout([background, partnerImageView, pointsView, titleLabel, redeemButton])

        background.constraintsToEdges(in: contentView).activate()
        [
            partnerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            partnerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin),
            partnerImageView.heightAnchor.constraint(equalToConstant: Layout.Size.brand.height),
            partnerImageView.heightAnchor.constraint(equalTo: partnerImageView.widthAnchor),

            pointsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            pointsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),

            titleLabel.topAnchor.constraint(equalTo: pointsView.bottomAnchor, constant: Metrics.veryBigMargin),
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
        pointsView.set(points: data.points)
        partnerImageView.image = data.partnerIcon
        background.image = data.background
        redeemButton.isEnabled = data.state == .enabled
    }
}

extension Reactive where Base: AffiliationStoreCell {
    var redeemTap: Observable<Void> {
        return base.redeemButton.rx.tap.asObservable()
    }
}
