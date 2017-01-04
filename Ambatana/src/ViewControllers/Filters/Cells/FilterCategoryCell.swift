//
//  FilterCategoryCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class FilterCategoryCell: UICollectionViewCell {

    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    @IBOutlet weak var rightSeparator: UIView!
    @IBOutlet weak var separatorWidth: NSLayoutConstraint!


    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        setAccessibilityIds()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        separatorHeight.constant = LGUIKitConstants.onePixelSize
        separatorWidth.constant = LGUIKitConstants.onePixelSize
        titleLabel.numberOfLines = 2
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        categoryIcon.image = nil
        titleLabel.text = ""
        rightSeparator.isHidden = true
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .FilterCategoryCell
        categoryIcon.accessibilityId = .FiltersCollectionView
        titleLabel.accessibilityId = .FiltersSaveFiltersButton
    }
}
