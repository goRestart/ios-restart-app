//
//  FilterLocationCell.swift
//  LetGo
//
//  Created by Eli Kohen Gomez on 24/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class FilterLocationCell: UICollectionViewCell {

    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        setupAccessibilityIds()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }


    // MARK: - Private methods

    private func setupUI() {
        separatorHeight.constant = LGUIKitConstants.onePixelSize
        titleLabel.text = LGLocalizedString.changeLocationTitle
    }

    // Resets the UI to the initial state
    private func resetUI() {
        locationLabel.text = nil
    }

    private func setupAccessibilityIds() {
        self.accessibilityId = .FilterLocationCell
        titleLabel.accessibilityId = .FilterLocationCellTitleLabel
        locationLabel.accessibilityId = .FilterLocationCellLocationLabel
    }
}
