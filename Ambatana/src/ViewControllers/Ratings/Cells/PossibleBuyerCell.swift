import UIKit
import LGComponents

enum DisclosureDirection {
    case down
    case up
    case right
}

enum RateBuyerCellType {
    case userCell
    case otherCell
}

final class PossibleBuyerCell: UITableViewCell, ReusableCell {
    private struct Layout {
        static let imageHeight: CGFloat = 36
        static let labelEdges = UIEdgeInsets(top: 0, left: 61, bottom: 7, right: 1)
    }
    static let cellHeight: CGFloat = 55

    private let userImage = UIImageView(image: R.Asset.IconsButtons.userPlaceholder.image)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 17)
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 12)
        return label
    }()

    private let disclosureImage: UIImageView = {
        let image = UIImageView(image: R.Asset.IconsButtons.icDisclosure.image)
        image.contentMode = .scaleAspectFit
        return image
    }()

    private var leftMarginLabelConstraint: NSLayoutConstraint?
    private var bottomMarginTitleConstraint: NSLayoutConstraint?

    private var separators = [UIView]()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        resetUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([userImage, titleLabel, subtitleLabel, disclosureImage])
        let bottomTitle = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                             constant: -Layout.labelEdges.bottom)
        let leadingTitle = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                               constant: Layout.labelEdges.left)
        NSLayoutConstraint.activate([
            userImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            userImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImage.widthAnchor.constraint(equalToConstant: Layout.imageHeight),
            userImage.heightAnchor.constraint(equalTo: userImage.widthAnchor),

            leadingTitle,
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.shortMargin),
            bottomTitle,
            titleLabel.trailingAnchor.constraint(equalTo: disclosureImage.leadingAnchor,
                                                 constant: -Layout.labelEdges.right),
            titleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),

            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.shortMargin),

            disclosureImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureImage.widthAnchor.constraint(equalToConstant: Metrics.margin),
            disclosureImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin)
        ])
        self.bottomMarginTitleConstraint = bottomTitle
        self.leftMarginLabelConstraint = leadingTitle
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    // MARK: - Public

    func setupWith(cellType: RateBuyerCellType, image imageUrl: URL?, title: String?, subtitle: String?, topBorder: Bool,
                   bottomBorder: Bool = true, disclouseDirection: DisclosureDirection) {
        
        switch cellType {
        case .userCell:
            if let imageUrl = imageUrl {
                userImage.lg_setImageWithURL(imageUrl)
            } else {
                userImage.image = R.Asset.IconsButtons.userPlaceholder.image
            }
            let leftMargin = bottomBorder ? 0 : Layout.labelEdges.left

            separators.append(addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize,
                                                      color: UIColor.lineGray,
                                                      leftMargin: leftMargin))
        case .otherCell:
            leftMarginLabelConstraint?.constant = Metrics.margin
            if bottomBorder {
                separators.append(addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize,
                                                      color: UIColor.lineGray))
            }
        }
        
        titleLabel.text = title
        
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            bottomMarginTitleConstraint?.constant = -Metrics.veryBigMargin
        } else {
            bottomMarginTitleConstraint?.constant = -Layout.labelEdges.bottom
        }
        
        if topBorder {
            separators.append(addTopViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.lineGray))
        }
        
        switch disclouseDirection {
        case .down:
            disclosureImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        case .up:
            disclosureImage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        case .right:
            break
        }
    }


    // MARK: - Private methods

    private func setupUI() {
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.bigBodyFont
        disclosureImage.image = R.Asset.IconsButtons.icDisclosure.image
        subtitleLabel.textColor = UIColor.grayDark
        subtitleLabel.font = UIFont.smallBodyFont
        titleLabel.set(accessibilityId: .passiveBuyerCellName)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.setRoundedCorners()
    }


    private func resetUI() {
        userImage.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        disclosureImage.transform = CGAffineTransform(rotationAngle: 0)
        leftMarginLabelConstraint?.constant = Layout.labelEdges.left
        bottomMarginTitleConstraint?.constant = -Layout.labelEdges.bottom
        separators.forEach { $0.removeFromSuperview() }
        separators.removeAll()
    }
}
