//
//  SellEmptyCell.swift
//  LetGo
//
//  Created by AHL on 16/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SellEmptyCell: UICollectionViewCell {

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
        
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        
    }
}
