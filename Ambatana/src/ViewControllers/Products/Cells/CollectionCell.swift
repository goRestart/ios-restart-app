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
        contentCell.layer.cornerRadius = LGUIKitConstants.productCellCornerRadius
        contentCell.clipsToBounds = true
        exploreButton.setStyle(.primary(fontSize: .small))
        exploreButton.setTitle(LGLocalizedString.collectionExploreButton, for: UIControlState())
        exploreButton.titleLabel?.adjustsFontSizeToFitWidth = true
        setAccessibilityIds()
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .collectionCell
        imageView.accessibilityId = .collectionCellImageView
        title.accessibilityId = .collectionCellTitle
        exploreButton.accessibilityId =  .collectionCellExploreButton
    }
}
