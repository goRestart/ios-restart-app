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
    @IBOutlet weak var exploreButton: UIButton!

    override var highlighted: Bool {
        didSet {
            alpha = highlighted ? 0.8 : 1.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //UI setup
        contentView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        contentView.clipsToBounds = true
        exploreButton.setStyle(.Primary(fontSize: .Small))
        exploreButton.setTitle(LGLocalizedString.collectionExploreButton, forState: .Normal)
        setAccessibilityIds()
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .CollectionCell
        imageView.accessibilityId = .CollectionCellImageView
        title.accessibilityId = .CollectionCellTitle
        exploreButton.accessibilityId =  .CollectionCellExploreButton
    }
}
