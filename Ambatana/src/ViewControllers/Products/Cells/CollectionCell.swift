//
//  CollectionCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell, ReusableCell {

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
    }
}
