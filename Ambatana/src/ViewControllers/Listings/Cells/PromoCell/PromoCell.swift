import UIKit
import LGComponents

enum PromoCellArrangement {
    case imageOnTop, titleOnTop(showsPostButton: Bool)
}

final class PromoCell: UICollectionViewCell, ReusableCell {
    
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
    
    private let postButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .verySmall))
        button.setTitle(R.Strings.realEstatePromoPostButtonTitle, for: .normal)
        return button
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var stackViewTopAnchorConstraint: NSLayoutConstraint?
    private var stackViewBottomAnchorConstraint: NSLayoutConstraint?
    
    weak var delegate: ListingCellDelegate?
    private var cellType: PromoCellType?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    // MARK: - Public methods
    
    func setup(with data: PromoCellData) {
        setupTitle(with: data)
        setupAppearance(with: data.appearance)
        cellType = data.type
        icon.image = data.image
        postButton.addTarget(self, action: #selector(postNowButtonPressed), for: .touchUpInside)
        configure(stackViewWith: data.arrangement)
    }
    
    private func setupTitle(with data: PromoCellData) {
        
        if let attributedTitle = data.attributedTitle {
            titleLabel.attributedText = attributedTitle
        } else {
            titleLabel.text = data.title
        }
    }
    
    private func setupAppearance(with appearance: CellAppearance) {
        contentView.backgroundColor = appearance.backgroundColor
        titleLabel.textColor = appearance.titleColor
        postButton.setStyle(appearance.buttonStyle)
        backgroundImageView.image = appearance.backgroundImage
    }

    // MARK: - Private methods
    
    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postNowButtonPressed))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupUI() {
        contentView.clipsToBounds = true
        cornerRadius = LGUIKitConstants.mediumCornerRadius
        contentView.addSubviewsForAutoLayout([backgroundImageView, stackView])
    }
    
    private func resetUI() {
        titleLabel.attributedText = nil
        titleLabel.text = nil
        backgroundImageView.image = nil
        cellType = nil
        stackView.arrangedSubviews.forEach( { $0.removeFromSuperview() } )
        updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.margin,
                                           bottom: -PromoCellMetrics.Stack.bottomMargin)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                     backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                     backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                                     postButton.heightAnchor.constraint(equalToConstant: PromoCellMetrics.PostButton.height),
                                     postButton.widthAnchor.constraint(equalToConstant: PromoCellMetrics.PostButton.width),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                        constant: PromoCellMetrics.Stack.margin),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                         constant: -PromoCellMetrics.Stack.margin)])
        
        stackViewTopAnchorConstraint = stackView.topAnchor.constraint(equalTo: topAnchor,
                                                                      constant: PromoCellMetrics.Stack.margin)
        stackViewBottomAnchorConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                            constant: -PromoCellMetrics.Stack.bottomMargin)
        stackViewTopAnchorConstraint?.isActive = true
        stackViewBottomAnchorConstraint?.isActive = true
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .realEstateCell)
        titleLabel.set(accessibilityId: .realEstatePromoTitle)
        icon.set(accessibilityId: .realEstatePromoIcon)
        postButton.set(accessibilityId: .realEstatePromoPostNowButton)
    }
    
    private func configure(stackViewWith arrangement: PromoCellArrangement) {
        switch arrangement {
        case .imageOnTop:
            stackView.addArrangedSubview(icon)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(postButton)
            updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.margin,
                                               bottom: -PromoCellMetrics.Stack.bottomMargin)
        case .titleOnTop(let showsPostButton):
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(icon)
            if showsPostButton {
                stackView.addArrangedSubview(postButton)
                updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.margin,
                                                   bottom: -PromoCellMetrics.Stack.bottomMargin)
            } else {
                updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.largeMargin,
                                                   bottom: -PromoCellMetrics.Stack.largeBottomMargin)
            }
        }
    }
    
    private func updateStackViewVerticalConstraints(top topValue: CGFloat,
                                                    bottom bottomValue: CGFloat) {
        stackViewTopAnchorConstraint?.constant = topValue
        stackViewBottomAnchorConstraint?.constant = bottomValue
    }
    
    @objc private func postNowButtonPressed() {
        guard let postCategory = cellType?.postCategory,
            let postingSource = cellType?.postingSource else { return }
        delegate?.postNowButtonPressed(self,
                                       category: postCategory,
                                       source: postingSource)
    }
}

private extension CellAppearance {
    
    var backgroundColor: UIColor {
        switch self {
        case .dark:
            return .lgBlack
        case .light, .backgroundImage:
            return .white
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return .redText
        case .backgroundImage(_, let titleColor, _):
            return titleColor
        }
    }
    
    var buttonStyle: ButtonStyle {
        switch self {
        case .dark, .light:
            return .primary(fontSize: .verySmall)
        case .backgroundImage(_, _, let buttonStyle):
            return buttonStyle
        }
    }
    
    var backgroundImage: UIImage? {
        switch self {
        case .dark, .light:
            return nil
        case .backgroundImage(let image, _, _):
            return image
        }
    }
}
