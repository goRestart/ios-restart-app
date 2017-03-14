//
//  GalleryImageCell.swift
//  LetGo
//
//  Created by Eli Kohen on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class GalleryImageCell: UICollectionViewCell, ReusableCell {

    static var reusableID = "GalleryImageCell"

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var multipleSelectionCountLabel: UILabel!
    @IBOutlet weak var disabledView: UIView!
    @IBOutlet weak var singleSelectionCheck: UIImageView!

    var multipleSelectionEnabled: Bool = false

    var disabled: Bool = false {
        didSet {
            disabledView.isHidden = !disabled || !multipleSelectionEnabled
        }
    }
    
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

    override var isSelected: Bool {
        didSet {
            singleSelectionCheck.isHidden = !isSelected || multipleSelectionEnabled
            multipleSelectionCountLabel.isHidden = !isSelected || !multipleSelectionEnabled
            if multipleSelectionCountLabel.isHidden {
                multipleSelectionCountLabel.text = nil
            }
        }
    }

    // MARK: - Private methods

    // Sets up the UI
    private func setupUI() {

        singleSelectionCheck.image = UIImage(named: "ic_post_ok")
        singleSelectionCheck.layer.borderWidth = 2
        singleSelectionCheck.layer.cornerRadius = LGUIKitConstants.productCellCornerRadius
        singleSelectionCheck.layer.borderColor = UIColor.white.cgColor

        multipleSelectionCountLabel.text = nil

        multipleSelectionCountLabel.layer.borderWidth = 2
        multipleSelectionCountLabel.layer.cornerRadius = LGUIKitConstants.productCellCornerRadius
        multipleSelectionCountLabel.layer.borderColor = UIColor.white.cgColor
    }

    // Resets the UI to the initial state
    private func resetUI() {
        image.image = nil

        singleSelectionCheck.isHidden = true

        multipleSelectionCountLabel.text = nil
        multipleSelectionCountLabel.isHidden = true
        disabled = false

        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = LGUIKitConstants.galleryCellCornerRadius
    }
}
