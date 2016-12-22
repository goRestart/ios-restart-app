//
//  UserRatingCell.swift
//  LetGo
//
//  Created by Dídac on 18/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

extension UserRatingType {

    func ratingTypeText(userName: String) -> String {
        switch self {
        case .Conversation:
            return LGLocalizedString.ratingListRatingTypeConversationTextLabel(userName)
        case .Seller:
            return LGLocalizedString.ratingListRatingTypeSellerTextLabel(userName)
        case .Buyer:
            return LGLocalizedString.ratingListRatingTypeBuyerTextLabel(userName)
        }
    }

    var ratingTypeTextColor: UIColor {
        switch self {
        case .Conversation:
            return UIColor.blackText
        case .Seller:
            return UIColor.soldText
        case .Buyer:
            return UIColor.redText
        }
    }
}

struct UserRatingCellData {
    var userName: String
    var userAvatar: NSURL?
    var userAvatarPlaceholder: UIImage?
    var ratingType: UserRatingType
    var ratingValue: Int
    var ratingDescription: String?
    var ratingDate: NSDate
    var isMyRating: Bool
    var pendingReview: Bool
}

protocol UserRatingCellDelegate: class {
    func actionButtonPressedForCellAtIndex(indexPath: NSIndexPath)
}

class UserRatingCell: UITableViewCell {

    private static let ratingTypeLeadingWIcon: CGFloat = 16

    static var emptyStarImage = "ic_star"
    static var fullStarImage = "ic_star_filled"

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

    private var cellIndex: NSIndexPath?

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
    }


    // MARK: public methods

    func setupRatingCellWithData(data: UserRatingCellData, indexPath: NSIndexPath) {
        let tag = indexPath.hash
        cellIndex = indexPath

        userNameLabel.text = data.userName

        ratingTypeLabelLeadingConstraint.constant = data.pendingReview ? UserRatingCell.ratingTypeLeadingWIcon : 0
        ratingTypeIcon.hidden = !data.pendingReview
        ratingTypeLabel.textColor = data.pendingReview ? UIColor.blackText : data.ratingType.ratingTypeTextColor
        ratingTypeLabel.text = data.pendingReview ? LGLocalizedString.ratingListRatingStatusPending :
            data.ratingType.ratingTypeText(data.userName)

        if let description = data.ratingDescription where description != "" {
            timeLabelTopConstraint.constant = 5
            descriptionLabel.text = description
        }

        actionsButton.hidden = !data.isMyRating || data.pendingReview

        userAvatar.image = data.userAvatarPlaceholder
        if let avatarURL = data.userAvatar {
            userAvatar.lg_setImageWithURL(avatarURL, placeholderImage: data.userAvatarPlaceholder) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image where self?.tag == tag {
                    self?.userAvatar.image = image
                }
            }
        }
        userAvatar.layer.cornerRadius = userAvatar.height/2
        timeLabel.text = data.ratingDate.relativeTimeString(false)
        drawStarsForValue(data.ratingValue)
    }

    @IBAction func actionsButtonPressed(sender: AnyObject) {
        guard let index = cellIndex else { return }
        delegate?.actionButtonPressedForCellAtIndex(index)
    }


    // MARK: - Private methods

    private func setupUI() {
        userNameLabel.textColor = UIColor.blackText
        userNameLabel.accessibilityId = .RatingListCellUserName
        ratingTypeLabel.textColor = UIColor.blackText
        descriptionLabel.textColor = UIColor.darkGrayText
        timeLabel.textColor = UIColor.darkGrayText
        userAvatar.layer.cornerRadius = userAvatar.height/2
    }

    // Resets the UI to the initial state
    private func resetUI() {
        userNameLabel.text = ""
        ratingTypeLabel.text = ""
        descriptionLabel.text = nil
        actionsButton.hidden = true
        userAvatar.image = nil
        timeLabel.text = ""
        timeLabelTopConstraint.constant = 0
    }

    private func drawStarsForValue(value: Int) {
        stars.forEach{
            $0.image = ($0.tag <= value) ? UIImage(named: UserRatingCell.fullStarImage) : UIImage(named: UserRatingCell.emptyStarImage)
        }
    }
}
