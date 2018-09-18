import LGComponents

struct AffiliationPoints {
    let points: UInt
}

private enum Layout {
    enum Size {
        static let container = CGSize(width: 88, height: 32)
    }
    static let labelTrailing: CGFloat = 12
    static let shortMargin: CGFloat = 4
    static let margin: CGFloat = 8
    static let pointsWidth: CGFloat = 24
}
extension AffiliationPoints: CustomStringConvertible {
    var description: String { return "\(points) Pts"} // TODO format (M, K, etc) & localize
}

final class AffiliationStorePointsView: UIView {
    override var intrinsicContentSize: CGSize { return Layout.Size.container }

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 14)
        label.textColor = .lgBlack
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let pointsIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.Asset.Affiliation.icnAffiliationPoints.image
        return imageView
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.borderColor = UIColor.grayLight.cgColor
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1

        addSubviewsForAutoLayout([container, pointsIcon, pointsLabel])
        [
            container.heightAnchor.constraint(equalToConstant: Layout.Size.container.height),
            container.widthAnchor.constraint(equalToConstant: Layout.Size.container.width),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),

            pointsIcon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.margin),
            pointsIcon.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.shortMargin),
            pointsIcon.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Layout.shortMargin),
            pointsIcon.widthAnchor.constraint(equalToConstant: Layout.pointsWidth),

            pointsLabel.leadingAnchor.constraint(equalTo: pointsIcon.trailingAnchor, constant: Layout.shortMargin),
            pointsLabel.centerYAnchor.constraint(equalTo: pointsIcon.centerYAnchor),
            pointsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.labelTrailing)
        ].activate()
    }

    func populate(with points: AffiliationPoints) {
        pointsLabel.text = points.description
    }
}
