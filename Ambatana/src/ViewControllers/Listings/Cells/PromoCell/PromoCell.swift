import UIKit
import LGComponents

enum PromoCellArrangement {
    case imageOnTop, titleOnTop
}

final class PromoCell: UICollectionViewCell, ReusableCell {
    
    weak var delegate: ListingCellDelegate?
    
    //  MARK: - Subviews

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = Metrics.shortMargin
        return stackView
    }()

    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .center
        icon.clipsToBounds = true
        return icon
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = PromoCellMetrics.Title.font
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let postButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .verySmall))
        button.setTitle(R.Strings.realEstatePromoPostButtonTitle, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Public methods
    
    func setup(with data: PromoCellData) {
        contentView.backgroundColor = data.appereance.backgroundColor
        titleLabel.textColor = data.appereance.titleColor
        titleLabel.text = data.title
        icon.image = data.image
        postButton.addTarget(self, action: #selector(postNowButtonPressed), for: .touchUpInside)
        configure(stackViewWith: data.arrangement)
    }

    // MARK: - Private methods
    
    private func setupUI() {
        contentView.clipsToBounds = true
        cornerRadius = LGUIKitConstants.mediumCornerRadius
        contentView.addSubviewForAutoLayout(stackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([postButton.heightAnchor.constraint(equalToConstant: PromoCellMetrics.PostButton.height),
                                     postButton.widthAnchor.constraint(equalToConstant: PromoCellMetrics.PostButton.width),
                                     stackView.topAnchor.constraint(equalTo: topAnchor, constant: PromoCellMetrics.Stack.margin),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PromoCellMetrics.Stack.margin),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PromoCellMetrics.Stack.margin),
                                     stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -PromoCellMetrics.Stack.bottomMargin)])
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .realEstateCell)
        titleLabel.set(accessibilityId: .realEstatePromoTitle)
        icon.set(accessibilityId: .realEstatePromoIcon)
        postButton.set(accessibilityId: .realEstatePromoPostNowButton)
    }
    
    private func configure(stackViewWith arrangement: PromoCellArrangement) {
        if case .imageOnTop = arrangement {
            stackView.addArrangedSubview(icon)
            stackView.addArrangedSubview(titleLabel)
        } else {
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(icon)
        }
        stackView.addArrangedSubview(postButton)
    }
    
    @objc private func postNowButtonPressed() {
        delegate?.postNowButtonPressed(self)
    }

}

private extension CellAppereance {
    
    var backgroundColor: UIColor {
        switch self {
        case .dark:
            return UIColor.lgBlack
        case .light:
            return .white
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return UIColor.redText
        }
    }
}
