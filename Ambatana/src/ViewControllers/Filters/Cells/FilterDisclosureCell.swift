//
//  FilterLocationCell.swift
//  LetGo
//
//  Created by Eli Kohen Gomez on 24/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class FilterDisclosureCell: UICollectionViewCell, ReusableCell {

    
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!


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
    }

    // Resets the UI to the initial state
    private func resetUI() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        titleLabel.isEnabled = true
        isUserInteractionEnabled = true
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .filterDisclosureCell
        titleLabel.accessibilityId = .filterDisclosureCellTitleLabel
        subtitleLabel.accessibilityId = .filterDisclosureCellSubtitleLabel
    }
}
