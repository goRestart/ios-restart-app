import UIKit
import LGComponents

class CollectionCell: UICollectionViewCell, ReusableCell {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let colorView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let containerView: UIView = {
        let view = UIView()
        return view
    }()

    private let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()

    private let exploreButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .small))
        button.setTitle(R.Strings.collectionExploreButton, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }
    
    private let exploreButtonHeight: CGFloat = 30

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        cornerRadius = LGUIKitConstants.mediumCornerRadius
        setupViews()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage?, titleText: String) {
        imageView.image = image
        title.text = titleText
        title.font = UIFont.systemBoldFont(size: title.fontSizeAdjusted())
    }

    private func setupViews() {
        contentView.addSubviewsForAutoLayout([imageView, colorView, containerView])
        imageView.layout(with: contentView).fill()
        colorView.layout(with: contentView).fill()
        let horizontalMargin: CGFloat = 4
        let verticalMargin: CGFloat = 6
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalMargin),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalMargin),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalMargin),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalMargin)
        ])
        layoutViewsInContainerView()
    }

    private func layoutViewsInContainerView() {
        containerView.addSubviewsForAutoLayout([title, exploreButton])
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            title.topAnchor.constraint(equalTo: containerView.topAnchor),
            title.bottomAnchor.constraint(equalTo: exploreButton.topAnchor)
        ])

        NSLayoutConstraint.activate([
            exploreButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            exploreButton.heightAnchor.constraint(equalToConstant: exploreButtonHeight),
            exploreButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .collectionCell)
        imageView.set(accessibilityId: .collectionCellImageView)
        title.set(accessibilityId: .collectionCellTitle)
        exploreButton.set(accessibilityId: .collectionCellExploreButton)
    }
}
