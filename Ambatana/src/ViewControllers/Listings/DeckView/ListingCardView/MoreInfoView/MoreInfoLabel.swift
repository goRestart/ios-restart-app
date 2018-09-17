import LGComponents

final class MoreInfoLabel: MoreInfoViewType {
    override var intrinsicContentSize: CGSize {
        switch stackView.axis {
        case .vertical:
            let label = moreInfoLabel.intrinsicContentSize
            return CGSize(width: label.width,
                          height: label.height + imageView.height)
        case .horizontal:
            let label = moreInfoLabel.intrinsicContentSize
            return CGSize(width: label.width + imageView.width, height: moreInfoLabel.height)
        }
    }
    private let stackView: UIStackView

    private let moreInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 15)
        label.textColor = .white
        label.text = R.Strings.productMoreInfoOpenButton
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.NewItemPage.nitArrowDown.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init(axis: UILayoutConstraintAxis) {
        let views = [moreInfoLabel, imageView]
        switch axis {
        case .horizontal:
            stackView = UIStackView.horizontal(views)
            stackView.spacing = Metrics.shortMargin
        case .vertical:
            stackView = UIStackView.vertical(views)
            stackView.spacing = Metrics.veryShortMargin
        }
        stackView.alignment = .fill
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewForAutoLayout(stackView)
        stackView.constraintsToEdges(in: self).activate()
    }

    func setupWith(title: String, price: String) {
        // do nothing, know nothing
    }

}
