//
//  SellAddPictureCell.swift
//  LetGo
//
//  Created by AHL on 16/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SellAddPictureCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    
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

    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        label.text = LGLocalizedString.sellPictureLabel
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        
    }
}
