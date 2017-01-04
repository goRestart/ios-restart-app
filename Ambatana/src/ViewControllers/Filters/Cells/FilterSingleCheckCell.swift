//
//  FilterSingleCheckCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class FilterSingleCheckCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tickIcon: UIImageView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeight: NSLayoutConstraint!
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
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            self.tickIcon.isHidden = !newValue
        }
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        bottomSeparatorHeight.constant = LGUIKitConstants.onePixelSize
        topSeparatorHeight.constant = LGUIKitConstants.onePixelSize
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        tickIcon.isHidden = true
        titleLabel.text = ""
        bottomSeparator.isHidden = true
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .FilterSingleCheckCell
        tickIcon.accessibilityId = .FilterSingleCheckCellTickIcon
        titleLabel.accessibilityId = .FilterSingleCheckCellTitleLabel
    }
}
