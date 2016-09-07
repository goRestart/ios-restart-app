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
    @IBOutlet weak var tickIcon: UIImageView!

    @IBOutlet weak var separatorHeight: NSLayoutConstraint!


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

    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            super.selected = newValue
            self.tickIcon.hidden = !newValue
        }
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        separatorHeight.constant = LGUIKitConstants.onePixelSize
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        categoryIcon.image = nil
        tickIcon.hidden = true
        titleLabel.text = ""
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .FilterCategoryCell
        categoryIcon.accessibilityId = .FiltersCollectionView
        titleLabel.accessibilityId = .FiltersSaveFiltersButton
    }
}
