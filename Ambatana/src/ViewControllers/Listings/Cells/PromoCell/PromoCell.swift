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
        icon.contentMode = .scaleAspectFit
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
    
    private let postButton: LetgoButton = LetgoButton(withStyle: .primary(fontSize: .verySmall))
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private var stackViewTopAnchorConstraint: NSLayoutConstraint?
    private var postButtonBottomAnchorConstraint: NSLayoutConstraint?
    private var postButtonHeightConstraint: NSLayoutConstraint?
    private var postButtonWidthConstraint: NSLayoutConstraint?
    
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
        postButton.setTitle(appearance.buttonTitle, for: .normal)
        backgroundImageView.image = appearance.backgroundImage
        
        updatePostButtonWidth(forTitle: appearance.buttonTitle,
                              withFont: appearance.buttonStyle.titleFont)
    }
    
    
    private func updatePostButtonWidth(forTitle title: String?,
                                       withFont font: UIFont) {
        guard let title = title else {
            postButtonWidthConstraint?.constant = PromoCellMetrics.PostButton.width
            return
        }
        
        let stringWidth = title.widthFor(height: PromoCellMetrics.PostButton.height,
                                         font: font)
        let desiredWidth = stringWidth+PromoCellMetrics.PostButton.horizontalInsets
        
        postButtonWidthConstraint?.constant = desiredWidth
    }

    // MARK: - Private methods
    
    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postNowButtonPressed))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupUI() {
        contentView.clipsToBounds = true
        cornerRadius = LGUIKitConstants.mediumCornerRadius
        contentView.addSubviewsForAutoLayout([backgroundImageView, stackView, postButton])
    }
    
    private func resetUI() {
        titleLabel.attributedText = nil
        titleLabel.text = nil
        backgroundImageView.image = nil
        cellType = nil
        stackView.arrangedSubviews.forEach( { $0.removeFromSuperview() } )
        updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.margin,
                                           bottom: -PromoCellMetrics.PostButton.bottomMargin)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                     backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                     backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                        constant: PromoCellMetrics.Stack.margin),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                         constant: -PromoCellMetrics.Stack.margin),
                                     postButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     postButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Metrics.bigMargin)])
        
        stackViewTopAnchorConstraint = stackView.topAnchor.constraint(equalTo: topAnchor,
                                                                      constant: PromoCellMetrics.Stack.margin)
        postButtonHeightConstraint = postButton.heightAnchor.constraint(equalToConstant: PromoCellMetrics.PostButton.height)
        postButtonBottomAnchorConstraint = postButton.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                            constant: -PromoCellMetrics.PostButton.bottomMargin)
        postButtonWidthConstraint = postButton.widthAnchor.constraint(equalToConstant: PromoCellMetrics.PostButton.width)
        
        postButtonHeightConstraint?.isActive = true
        stackViewTopAnchorConstraint?.isActive = true
        postButtonBottomAnchorConstraint?.isActive = true
        postButtonWidthConstraint?.isActive = true
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .promoCell)
        titleLabel.set(accessibilityId: .promoCellTitle)
        icon.set(accessibilityId: .promoCellIcon)
        postButton.set(accessibilityId: .promoCellPostNowButton)
    }
    
    private func configure(stackViewWith arrangement: PromoCellArrangement) {
        switch arrangement {
        case .imageOnTop:
            stackView.addArrangedSubview(icon)
            stackView.addArrangedSubview(titleLabel)
            updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.margin,
                                               bottom: -PromoCellMetrics.PostButton.bottomMargin)
        case .titleOnTop(let showsPostButton):
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(icon)
            postButtonHeightConstraint?.constant = showsPostButton ? PromoCellMetrics.PostButton.height : 0
            if showsPostButton {
                updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.margin,
                                                   bottom: -PromoCellMetrics.PostButton.bottomMargin)
            } else {
                updateStackViewVerticalConstraints(top: PromoCellMetrics.Stack.largeMargin,
                                                   bottom: -PromoCellMetrics.Stack.largeBottomMargin)
            }
        }
    }
    
    private func updateStackViewVerticalConstraints(top topValue: CGFloat,
                                                    bottom bottomValue: CGFloat) {
        stackViewTopAnchorConstraint?.constant = topValue
        postButtonBottomAnchorConstraint?.constant = bottomValue
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
        case .backgroundImage(_, let titleColor, _, _):
            return titleColor
        }
    }
    
    var buttonStyle: ButtonStyle {
        switch self {
        case .dark, .light:
            return .primary(fontSize: .verySmall)
        case .backgroundImage(_, _, let buttonStyle, _):
            return buttonStyle
        }
    }
    
    var backgroundImage: UIImage? {
        switch self {
        case .dark, .light:
            return nil
        case .backgroundImage(let image, _, _, _):
            return image
        }
    }
    
    var buttonTitle: String? {
        switch self {
        case .dark(let buttonTitle), .light(let buttonTitle):
            return buttonTitle
        case .backgroundImage(_, _, _, let buttonTitle):
            return buttonTitle
        }
    }
}
