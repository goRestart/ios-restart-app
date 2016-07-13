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
    
    override func awakeFromNib() {
        contentView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        contentView.clipsToBounds = true
        if FeatureFlags.mainProducts3Columns {
            title.font = UIFont.systemBoldFont(size: 17)
        } else {
            title.font = UIFont.systemBoldFont(size: 19)
        }
    }
}
