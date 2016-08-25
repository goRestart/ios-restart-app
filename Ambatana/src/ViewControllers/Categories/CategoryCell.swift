//
//  CategoryCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 14/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        self.setAccessibilityIds()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        self.contentView.layer.borderColor = UIColor.lineGray.CGColor
        self.contentView.layer.borderWidth = 0.25
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        imageView.image = nil
        titleLabel.text = ""
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .CategoryCell
        titleLabel.accessibilityId = .CategoryCellTitleLabel
        imageView.accessibilityId = .CategoryCellImageView
    }
}
