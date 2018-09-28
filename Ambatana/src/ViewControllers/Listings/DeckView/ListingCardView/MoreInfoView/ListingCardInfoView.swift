final class ListingCardInfoView: MoreInfoViewType {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 21)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemMediumFont(size: 15)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let moreInfoLabel = MoreInfoLabel(axis: .horizontal)

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let top = UIStackView.horizontal([titleLabel, UIView()])
        let bottom = UIStackView.horizontal([priceLabel, UIView(), moreInfoLabel])
        let vertical = UIStackView.vertical([top, bottom])

        addSubviewForAutoLayout(vertical)
        vertical.constraintToEdges(in: self)
    }

    func setupWith(title: String, price: String) {
        titleLabel.text = title
        priceLabel.text = price
    }
}
