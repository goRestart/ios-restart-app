//
//  PassiveBuyerCell.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class PassiveBuyerCell: UITableViewCell, ReusableCell {

    static let cellHeight: CGFloat = 50
    private static let imageHeight: CGFloat = 36

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!

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

    func setupWith(_ imageUrl: URL?, name: String?, firstCell: Bool, lastCell: Bool) {
        if let imageUrl = imageUrl {
            userImage.lg_setImageWithURL(imageUrl)
        }
        userName.text = name

        if firstCell {
            separators.append(addTopViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.lineGray))
            separators.append(addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.lineGray, leftMargin: 52))
        } else if lastCell {
            separators.append(addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.lineGray))
        } else {
            separators.append(addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.lineGray, leftMargin: 52))
        }
    }


    // MARK: - Private methods

    private func setupUI() {
        userImage.cornerRadius = PassiveBuyerCell.imageHeight / 2
        userName.textColor = UIColor.blackText
        userName.font = UIFont.bigBodyFont

        userName.accessibilityId = .passiveBuyerCellName
    }


    private func resetUI() {
        userImage.image = UIImage(named: "user_placeholder")
        userName.text = nil
        separators.forEach { $0.removeFromSuperview() }
        separators.removeAll()
    }
}
