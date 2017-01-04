//
//  FilterDistanceCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol FilterDistanceCellDelegate: class {
    func filterDistanceChanged(_ filterDistanceCell: FilterDistanceCell)
}


class FilterDistanceCell: UICollectionViewCell {
    
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var farIcon: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceTip: UIView!
    @IBOutlet weak var tipTopBackground: UIImageView!
    @IBOutlet weak var distanceTipCenter: NSLayoutConstraint!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var marksContainer: UIView!
    
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    
    //Static positions
    private let positions : [Int] = Constants.distanceFilterOptions
    
    weak var delegate : FilterDistanceCellDelegate?
    
    var distance : Int {
        return currentDistance()
    }
    
    var distanceType : DistanceType = .Km
    
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
    
    // MARK: - Public methods
    func setupWithDistance(_ initialDistance: Int) {

        layoutIfNeeded()
        
        for i in 0..<positions.count {
            if(positions[i] == initialDistance){
                setupInPosition(i)
                return
            }
        }
        setupInPosition(0) //First option
    }
    
    // MARK: - Internal methods

    @IBAction func sliderDidStart(_ sender: UISlider) {
        //Highlighted state
        closeIcon.isHighlighted = true
        farIcon.isHighlighted = true
    }
    
    @IBAction func sliderDidEnd(_ sender: UISlider) {
        //Highlighted state
        closeIcon.isHighlighted = false
        farIcon.isHighlighted = false
        
        //Position stick to some values
        let index = Int(slider.value + 0.5)
        setupInPosition(index)
        
        delegate?.filterDistanceChanged(self)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let percent = sender.value / sender.maximumValue
        updateTipPosition(percent)
        updateTipLabel()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        separatorHeight.constant = LGUIKitConstants.onePixelSize
        
        tipTopBackground.layer.cornerRadius = floor(tipTopBackground.frame.size.height / 2)
        slider.maximumValue = Float(positions.count-1)
        slider.minimumValue = 0.0
        
        //Add marks
        for i in 0..<positions.count {
            
            let percent = Float(i) / Float(positions.count - 1)
            let xPos = sliderCenterPosition(percent)
            let xPercent = xPos / marksContainer.frame.size.width
            
            let item = UIView(frame: CGRect(x: xPos, y: 0, width: 1, height: marksContainer.frame.size.height))
            item.translatesAutoresizingMaskIntoConstraints = false
            marksContainer.addSubview(item)
            
            let horizontalConstraint = NSLayoutConstraint(item: item, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: marksContainer, attribute: NSLayoutAttribute.trailing, multiplier: xPercent, constant: 0)
            marksContainer.addConstraint(horizontalConstraint)
            let verticalConstraint = NSLayoutConstraint(item: item, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: marksContainer, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            marksContainer.addConstraint(verticalConstraint)
            let widthConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[item(==1)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["item":item])
            item.addConstraints(widthConstraint)
            let heightConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[item(==\(marksContainer.frame.size.height))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["item":item])
            item.addConstraints(heightConstraint)
            item.backgroundColor = UIColor(rgb: 0xb6b6b6)
        }
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        distanceLabel.text = ""
        updateTipPosition(0)
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .FilterDistanceCell
        slider.accessibilityId = .FilterDistanceSlider
        distanceTip.accessibilityId = .FilterDistanceTip
        distanceLabel.accessibilityId = .FilterDistanceLabel
    }

    private func setupInPosition(_ position: Int){
        slider.setValue(Float(position), animated: true)
        let percent = slider.value / slider.maximumValue
        updateTipPosition(percent)
        updateTipLabel()
    }
    
    private func updateTipPosition(_ percentage: Float) {
        distanceTipCenter.constant = sliderCenterPosition(percentage)
    }
    
    private func sliderCenterPosition(_ percentage: Float) -> CGFloat {
        //26 is the size of slider button
        return ((marksContainer.frame.size.width-26) * CGFloat(percentage)) + 13
    }
    
    private func updateTipLabel() {
        
        let currDist = currentDistance()
        if(currDist == positions.first) {
            //First option (0) means no distance
            distanceLabel.text = LGLocalizedString.filtersDistanceNotSet
        }else if(currDist == positions.last) {
            //Last option (100) will have the string: "max"
            distanceLabel.text = LGLocalizedString.commonMax
        } else {
            distanceLabel.text = "\(currentDistance()) \(distanceType.string)"
        }
    }
    
    private func currentDistance() -> Int {
        let index = Int(slider.value + 0.5)
        return positions[index]
    }
}
