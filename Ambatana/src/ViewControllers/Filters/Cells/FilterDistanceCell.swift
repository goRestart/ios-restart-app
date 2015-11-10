//
//  FilterDistanceCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

class FilterDistanceCell: UICollectionViewCell {
    
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var farIcon: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceTip: UIView!
    @IBOutlet weak var tipTopBackground: UIImageView!
    @IBOutlet weak var distanceTipCenter: NSLayoutConstraint!
    @IBOutlet weak var distanceLabel: UILabel!
    
    //Static positions
    private let positions = [1, 5, 10, 20, 30];
    
    var distance : Int {
        return currentDistance()
    }
    
    var distanceType : DistanceType = .Km
    
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
    
    // MARK: - Public methods
    func setupWithDistance(initialDistance: Int) {
        for i in 0...positions.count {
            if(positions[i] == initialDistance){
                setupInPosition(i)
                return
            }
        }
        setupInPosition(2) //Just in the middle
    }
    
    // MARK: - Internal methods

    @IBAction func sliderDidStart(sender: UISlider) {
        //Highlighted state
        closeIcon.highlighted = true
        farIcon.highlighted = true
    }
    
    @IBAction func sliderDidEnd(sender: UISlider) {
        //Highlighted state
        closeIcon.highlighted = false
        farIcon.highlighted = false
        
        //Position stick to some values
        let index = Int(slider.value + 0.5)
        setupInPosition(index)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let percent = sender.value / sender.maximumValue
        updateTipPosition(percent)
        updateTipLabel()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        tipTopBackground.layer.cornerRadius = floor(tipTopBackground.frame.size.height / 2)
        slider.maximumValue = Float(positions.count-1)
        slider.minimumValue = 0.0
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        distanceLabel.text = ""
        updateTipPosition(0)
    }
    
    private func setupInPosition(position: Int){
        slider.setValue(Float(position), animated: true)
        let percent = slider.value / slider.maximumValue
        updateTipPosition(percent)
        updateTipLabel()
    }
    
    private func updateTipPosition(percentage: Float) {
        distanceTipCenter.constant = ((slider.frame.size.width-30) * CGFloat(percentage))+13
    }
    
    private func updateTipLabel() {
        var distanceNumber = currentDistance()
        switch (distanceType) {
        case .Km:
            distanceNumber = distanceNumber * 1
        case .Mi:
            distanceNumber = Int(Float(distanceNumber) * 0.621371)
        }
        
        distanceLabel.text = "\(distanceNumber) \(distanceType.string)"
    }
    
    private func currentDistance() -> Int {
        let index = Int(slider.value + 0.5)
        return positions[index]
    }
    
}
