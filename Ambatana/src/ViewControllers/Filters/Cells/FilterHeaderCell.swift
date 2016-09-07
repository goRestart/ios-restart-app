//
//  FilterHeaderCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class FilterHeaderCell: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    
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
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        titleLabel.text = ""
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .FilterHeaderCell
        titleLabel.accessibilityId = .FilterHeaderCellTitleLabel
    }
}
