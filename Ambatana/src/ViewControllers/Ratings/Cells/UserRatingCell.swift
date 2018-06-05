import UIKit
import LGCoreKit
import LGComponents

extension UserRatingType {

    func ratingTypeText(_ userName: String) -> String {
        switch self {
        case .conversation:
            return R.Strings.ratingListRatingTypeConversationTextLabel(userName)
        case .seller:
            return R.Strings.ratingListRatingTypeSellerTextLabel(userName)
        case .buyer:
            return R.Strings.ratingListRatingTypeBuyerTextLabel(userName)
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

class UserRatingCell: UITableViewCell, ReusableCell {

    private static let ratingTypeLeadingWIcon: CGFloat = 16

    static var emptyStarImage = "ic_star"
    static var fullStarImage = "ic_user_profile_star"

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet weak var ratingTypeIcon: UIImageView!
    @IBOutlet weak var ratingTypeLabel: UILabel!
    @IBOutlet weak var ratingTypeLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var actionsButton: UIButton!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!

    private var cellIndex: IndexPath?

    private var lines: [CALayer] = []

    weak var delegate: UserRatingCellDelegate?


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }

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

        ratingTypeLabelLeadingConstraint.constant = data.pendingReview ? UserRatingCell.ratingTypeLeadingWIcon : 0
        ratingTypeIcon.isHidden = !data.pendingReview
        ratingTypeLabel.textColor = data.pendingReview ? UIColor.blackText : data.ratingType.ratingTypeTextColor
        ratingTypeLabel.text = data.pendingReview ? R.Strings.ratingListRatingStatusPending :
            data.ratingType.ratingTypeText(data.userName)

        if let description = data.ratingDescription, description != "" {
            timeLabelTopConstraint.constant = 5
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

    @IBAction func actionsButtonPressed(_ sender: AnyObject) {
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

    // Resets the UI to the initial state
    private func resetUI() {
        userNameLabel.text = ""
        ratingTypeLabel.text = ""
        descriptionLabel.text = nil
        actionsButton.isHidden = true
        userAvatar.image = nil
        timeLabel.text = ""
        timeLabelTopConstraint.constant = 0
    }

    private func drawStarsForValue(_ value: Int) {
        let starImage = R.Asset.IconsButtons.icUserProfileStar.image
        stars.forEach{
            $0.image = starImage
            $0.alpha =  ($0.tag <= value) ? 1 : 0.4
        }
    }
}
