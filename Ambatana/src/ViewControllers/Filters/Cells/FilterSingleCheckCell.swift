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
        bottomSeparatorHeight.constant = StyleHelper.onePixelSize
        topSeparatorHeight.constant = StyleHelper.onePixelSize
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        tickIcon.hidden = true
        titleLabel.text = ""
        bottomSeparator.hidden = true
    }

}
