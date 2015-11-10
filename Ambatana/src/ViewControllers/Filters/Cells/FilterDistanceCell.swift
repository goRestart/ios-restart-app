//
//  FilterDistanceCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class FilterDistanceCell: UICollectionViewCell {
    
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var farIcon: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceTip: UIView!
    @IBOutlet weak var distanceTipCenter: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - Internal methods
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        print("Slider value: \(sender.value)")
        distanceTipCenter.constant = ((slider.frame.size.width-28) * CGFloat(sender.value))+14
        
    }
    
    
    // MARK: - Private methods
    
    // Resets the UI to the initial state
    private func resetUI() {
    }

}
