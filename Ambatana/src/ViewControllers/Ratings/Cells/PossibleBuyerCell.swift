//
//  PassiveBuyerCell.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

enum DisclosureDirection {
    case down
    case up
    case right
}

enum RateBuyerCellType {
    case userCell
    case otherCell
}

class PossibleBuyerCell: UITableViewCell, ReusableCell {

    static let cellHeight: CGFloat = 55
    private static let imageHeight: CGFloat = 36
    private static let leftMarginLabel: CGFloat = 61

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var disclosureImage: UIImageView!
    @IBOutlet weak var leftMarginLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMarginTitleConstraint: NSLayoutConstraint!

    private var separators = [UIView]()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetUI()
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
                userImage.image = UIImage(named: "user_placeholder")
            }
            let leftMargin = bottomBorder ? 0 : PossibleBuyerCell.leftMarginLabel
            separators.append(addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize,
                                                      color: UIColor.lineGray,
                                                      leftMargin: leftMargin))
        case .otherCell:
            leftMarginLabelConstraint.constant = Metrics.margin
            if bottomBorder {
                separators.append(addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize,
                                                      color: UIColor.lineGray))
            }
        }
        
        titleLabel.text = title
        
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            bottomMarginTitleConstraint.constant = Metrics.veryBigMargin
        } else {
            bottomMarginTitleConstraint.constant = 7
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
        userImage.cornerRadius = PossibleBuyerCell.imageHeight / 2
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.bigBodyFont
        disclosureImage.image = #imageLiteral(resourceName: "ic_disclosure")
        subtitleLabel.textColor = UIColor.grayDark
        subtitleLabel.font = UIFont.smallBodyFont
        titleLabel.accessibilityId = .passiveBuyerCellName
    }


    private func resetUI() {
        userImage.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        disclosureImage.transform = CGAffineTransform(rotationAngle: 0)
        leftMarginLabelConstraint.constant = PossibleBuyerCell.leftMarginLabel
        bottomMarginTitleConstraint.constant = 7
        separators.forEach { $0.removeFromSuperview() }
        separators.removeAll()
    }
}
