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
    @IBOutlet weak var tipTopBackground: UIImageView!
    @IBOutlet weak var distanceTipCenter: NSLayoutConstraint!
    @IBOutlet weak var distanceLabel: UILabel!
    
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
    
    // MARK: - Internal methods
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        print("Slider value: \(sender.value)")
        
        setTipPosition(sender.value)
    }
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        tipTopBackground.layer.cornerRadius = floor(tipTopBackground.frame.size.height / 2)
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        distanceLabel.text = "2 miles"
        setTipPosition(0)
    }
    
    private func setTipPosition(percentage: Float) {
        distanceTipCenter.constant = ((slider.frame.size.width-30) * CGFloat(percentage))+13
    }
}
