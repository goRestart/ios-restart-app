import UIKit
import LGComponents

class CollectionCell: UICollectionViewCell, ReusableCell {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
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

    private static let exploreButtonHeight: CGFloat = 30
    weak var selectedForYouDelegate: SelectedForYouDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        cornerRadius = LGUIKitConstants.mediumCornerRadius
        setupViews()
        addActions()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage?, titleText: String) {
        imageView.image = image
        titleLabel.text = titleText
    }

    private func setupViews() {
        contentView.addSubviewsForAutoLayout([imageView, titleLabel, exploreButton])
        imageView.layout(with: contentView).fill()
        let verticalMargin: CGFloat = 6
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.7),
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: verticalMargin),
            titleLabel.bottomAnchor.constraint(equalTo: exploreButton.topAnchor, constant: -verticalMargin),

            exploreButton.heightAnchor.constraint(equalToConstant: CollectionCell.exploreButtonHeight),
            exploreButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            exploreButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -verticalMargin)
            ])
    }

    private func addActions() {
        exploreButton.addTarget(self, action: #selector(handleExploreClicked), for: .touchUpInside)
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .collectionCell)
        imageView.set(accessibilityId: .collectionCellImageView)
        titleLabel.set(accessibilityId: .collectionCellTitle)
        exploreButton.set(accessibilityId: .collectionCellExploreButton)
    }

    @objc func handleExploreClicked() {
        selectedForYouDelegate?.openSelectedForYou()
    }
}
