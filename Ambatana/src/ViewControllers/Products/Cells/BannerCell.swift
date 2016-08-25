//
//  BannerCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 7/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class BannerCell: UICollectionViewCell, ReusableCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var colorView: UIView!

    override var highlighted: Bool {
        didSet {
            alpha = highlighted ? 0.8 : 1.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        contentView.clipsToBounds = true
        setAccessibilityIds()
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .BannerCell
        imageView.accessibilityId = .BannerCellImageView
        title.accessibilityId = .BannerCellTitle
    }
}
