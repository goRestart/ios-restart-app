//
//  CollectionCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell, ReusableCell {

    @IBOutlet weak var contentCell: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var exploreButton: UIButton!

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //UI setup
        contentCell.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        contentCell.clipsToBounds = true
        exploreButton.setStyle(.primary(fontSize: .small))
        exploreButton.setTitle(LGLocalizedString.collectionExploreButton, for: .normal)
        exploreButton.titleLabel?.adjustsFontSizeToFitWidth = true
        setAccessibilityIds()
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .collectionCell)
        imageView.set(accessibilityId: .collectionCellImageView)
        title.set(accessibilityId: .collectionCellTitle)
        exploreButton.set(accessibilityId:  .collectionCellExploreButton)
    }
}
