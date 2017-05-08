//
//  FilterCarInfoMakeModelCell.swift
//  LetGo
//
//  Created by Dídac on 03/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class FilterCarInfoMakeModelCell: UICollectionViewCell {

    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

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


    // MARK: - Private methods

    private func setupUI() {
        bottomSeparatorHeight.constant = LGUIKitConstants.onePixelSize
        topSeparatorHeight.constant = LGUIKitConstants.onePixelSize
    }

    // Resets the UI to the initial state
    private func resetUI() {
        infoLabel.text = nil
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .filterCarInfoMakeModelCell
        titleLabel.accessibilityId = .filterCarInfoMakeModelCellTitleLabel
        infoLabel.accessibilityId = .filterCarInfoMakeModelCellInfoLabel
    }

}
