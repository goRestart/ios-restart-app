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
    @IBOutlet weak var rightSeparator: UIView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - Private methods
    
    // Resets the UI to the initial state
    private func resetUI() {
        categoryIcon.image = nil
        titleLabel.text = ""
        rightSeparator.hidden = true
    }


}
