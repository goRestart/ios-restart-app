import UIKit
import LGCoreKit
import LGComponents

extension UserRatingType {

    func ratingTypeText(_ userName: String) -> String {
        switch self {
        case .conversation:
            return R.Strings.ratingListRatingTypeConversationTextLabel(userName)
        case .seller:
            return R.Strings.ratingListRatingTypeBuyerTextLabel(userName)
        case .buyer:
            return R.Strings.ratingListRatingTypeSellerTextLabel(userName)
        }
    }

    var ratingTypeTextColor: UIColor {
        switch self {
        case .conversation:
            return UIColor.blackText
        case .seller:
            return UIColor.soldText
        case .buyer:
            return UIColor.redText
        }
    }
}

struct UserRatingCellData {
    var userName: String
    var userAvatar: URL?
    var userAvatarPlaceholder: UIImage?
    var ratingType: UserRatingType
    var ratingValue: Int
    var ratingDescription: String?
    var ratingDate: Date
    var isMyRating: Bool
    var pendingReview: Bool
}

protocol UserRatingCellDelegate: class {
    func actionButtonPressedForCellAtIndex(_ indexPath: IndexPath)
}

final class UserRatingCell: UITableViewCell, ReusableCell {
    private struct Layout {
        static let margin: CGFloat = 8
        static let starsHeight: CGFloat = 12
        static let avatarWidth: CGFloat = 60
        static let ratingLabelHeight: CGFloat = 18
        static let ratingIconWidth: CGFloat = 12
        static let actionsWidth: CGFloat = 50
        static let actionsHeight: CGFloat = 34
    }
    private static let ratingTypeLeadingWIcon: CGFloat = 16

    private let userAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 17)
        return label
    }()

    private let starsStackView: UIStackView = {
        let stars: [UIImageView] = [UIImageView(image: R.Asset.IconsButtons.icStarFilled.image),
                                    UIImageView(image: R.Asset.IconsButtons.icStarFilled.image),
                                    UIImageView(image: R.Asset.IconsButtons.icStarFilled.image),
                                    UIImageView(image: R.Asset.IconsButtons.icStarFilled.image),
                                    UIImageView(image: R.Asset.IconsButtons.icStarFilled.image)]
        stars.forEach { $0.contentMode = .scaleAspectFit }
        let stackView: UIStackView = .horizontal(stars)
        stackView.distribution = .equalSpacing
        return stackView
    }()
    private var stars: [UIImageView] { return starsStackView.arrangedSubviews.flatMap { $0 as? UIImageView } }

    private let ratingTypeIcon: UIImageView = UIImageView(image: R.Asset.IconsButtons.icRatingPending.image)
    private let ratingTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 15)
        return label
    }()
    private var ratingTypeLabelLeadingConstraint: NSLayoutConstraint?
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 13)
        return label
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 13)
        return label
    }()
    private let actionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icMoreOptions.image, for: .normal)
        return button
    }()
    private var timeLabelTopConstraint: NSLayoutConstraint?

    private var cellIndex: IndexPath?
    private var lines: [CALayer] = []

    weak var delegate: UserRatingCellDelegate?


    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        resetUI()

        actionsButton.addTarget(self, action: #selector(actionsButtonPressed), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(contentView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
        
        userAvatar.setRoundedCorners()
    }


    // MARK: public methods

    func setupRatingCellWithData(_ data: UserRatingCellData, indexPath: IndexPath) {
        let tag = (indexPath as NSIndexPath).hash
        cellIndex = indexPath

        userNameLabel.text = data.userName

        ratingTypeLabelLeadingConstraint?.constant = data.pendingReview ? UserRatingCell.ratingTypeLeadingWIcon : 0
        ratingTypeIcon.isHidden = !data.pendingReview
        ratingTypeLabel.textColor = data.pendingReview ? UIColor.blackText : data.ratingType.ratingTypeTextColor
        ratingTypeLabel.text = data.pendingReview ? R.Strings.ratingListRatingStatusPending :
            data.ratingType.ratingTypeText(data.userName)

        if let description = data.ratingDescription, description != "" {
            timeLabelTopConstraint?.constant = 5
            descriptionLabel.text = description
        }

        actionsButton.isHidden = !data.isMyRating || data.pendingReview

        userAvatar.image = data.userAvatarPlaceholder
        if let avatarURL = data.userAvatar {
            userAvatar.lg_setImageWithURL(avatarURL, placeholderImage: data.userAvatarPlaceholder) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image, self?.tag == tag {
                    self?.userAvatar.image = image
                }
            }
        }
        timeLabel.text = data.ratingDate.relativeTimeString(false)
        drawStarsForValue(data.ratingValue)
    }

    @objc private func actionsButtonPressed(_ sender: AnyObject) {
        guard let index = cellIndex else { return }
        delegate?.actionButtonPressedForCellAtIndex(index)
    }


    // MARK: - Private methods

    private func setupUI() {
        userNameLabel.textColor = UIColor.blackText
        userNameLabel.set(accessibilityId: .ratingListCellUserName)
        ratingTypeLabel.textColor = UIColor.blackText
        descriptionLabel.textColor = UIColor.darkGrayText
        timeLabel.textColor = UIColor.darkGrayText
    }

    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([userAvatar, userNameLabel, actionsButton, starsStackView, ratingTypeIcon, ratingTypeLabel, descriptionLabel, timeLabel])

        let timeLabelTop = timeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,
                                                          constant: Layout.margin)
        let ratingTypeLabelLeading = ratingTypeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor, constant: 2*Layout.margin)
        NSLayoutConstraint.activate([
            userAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.shortMargin),
            userAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.shortMargin),
            userAvatar.widthAnchor.constraint(equalToConstant: Layout.avatarWidth),
            userAvatar.heightAnchor.constraint(equalTo: userAvatar.widthAnchor),

            userNameLabel.heightAnchor.constraint(equalToConstant: Metrics.bigMargin),
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: Layout.margin),

            actionsButton.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            actionsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.margin),
            actionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.margin),
            actionsButton.heightAnchor.constraint(equalToConstant: Layout.actionsHeight),
            actionsButton.widthAnchor.constraint(equalToConstant: Layout.actionsWidth),

            starsStackView.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: Layout.margin),
            starsStackView.centerYAnchor.constraint(equalTo: userAvatar.centerYAnchor),
            starsStackView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            starsStackView.heightAnchor.constraint(equalToConstant: Layout.starsHeight),

            ratingTypeIcon.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            ratingTypeIcon.topAnchor.constraint(equalTo: ratingTypeLabel.centerYAnchor),
            ratingTypeIcon.widthAnchor.constraint(equalToConstant: Layout.ratingIconWidth),
            ratingTypeIcon.heightAnchor.constraint(equalTo: ratingTypeIcon.widthAnchor),
            
            ratingTypeLabelLeading,
            ratingTypeLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor,
                                                 constant: Metrics.veryShortMargin),
            ratingTypeLabel.heightAnchor.constraint(equalToConstant: Layout.ratingLabelHeight),
            ratingTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.margin),

            descriptionLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: ratingTypeLabel.bottomAnchor, constant: Layout.margin),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.margin),

            timeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            timeLabelTop,
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.margin),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.margin)
            ])
        self.timeLabelTopConstraint = timeLabelTop
        self.ratingTypeLabelLeadingConstraint = ratingTypeLabelLeading
    }

    // Resets the UI to the initial state
    private func resetUI() {
        userNameLabel.text = ""
        ratingTypeLabel.text = ""
        descriptionLabel.text = nil
        actionsButton.isHidden = true
        userAvatar.image = nil
        timeLabel.text = ""
        timeLabelTopConstraint?.constant = 0
    }

    private func drawStarsForValue(_ value: Int) {
        let starImage = R.Asset.IconsButtons.icUserProfileStar.image
        stars.forEach{
            $0.image = starImage
            $0.alpha =  ($0.tag <= value) ? 1 : 0.4
        }
    }
}
