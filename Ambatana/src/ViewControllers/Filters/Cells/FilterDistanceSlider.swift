//
//  FilterDistanceSlider.swift
//  LetGo
//
//  Created by Nestor on 24/05/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol FilterDistanceSliderDelegate: class {
    func filterDistanceChanged(distance: Int)
}

class FilterDistanceSlider: UIView {
    
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var farIcon: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceTip: UIView!
    @IBOutlet weak var tipTopBackground: UIImageView!
    @IBOutlet weak var distanceTipCenter: NSLayoutConstraint!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var marksContainer: UIView!
    
    private static let sliderButtonSize: CGFloat = 26
    private static let sliderValueOffset: Float = 0.5
    private var marksContainerSize: CGSize {
        return marksContainer.frame.size
    }
    
    private let positions: [Int] = Constants.distanceSliderPositions
    private var selectedPosition: Int = Constants.distanceSliderDefaultPosition
    
    weak var delegate: FilterDistanceSliderDelegate?
    
    var distanceType: DistanceType = DistanceType.systemDistanceType()
    
    var distance: Int {
        set {
            layoutIfNeeded()
            let selectedPosition = (0..<positions.count)
                .filter { positions[$0] == newValue }
                .first ?? Constants.distanceSliderDefaultPosition
            setupInPosition(selectedPosition)
        }
        get {
            let index = Int(slider.value + FilterDistanceSlider.sliderValueOffset)
            return positions[index]
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // first time we set a distance the slider might not have the right size, so it will go through `layoutSubviews`
        // once it gets the final one
        setupInPosition(selectedPosition)
    }
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        
        setupUI()
        resetUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    @IBAction func sliderDidStart(_ sender: UISlider) {
        closeIcon.isHighlighted = true
        farIcon.isHighlighted = true
    }
    
    @IBAction func sliderDidEnd(_ sender: UISlider) {
        closeIcon.isHighlighted = false
        farIcon.isHighlighted = false
        
        //Position stick to some values
        let index = Int(slider.value + FilterDistanceSlider.sliderValueOffset)
        setupInPosition(index)
        
        delegate?.filterDistanceChanged(distance: distance)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let percent = sender.value / sender.maximumValue
        updateTipPosition(percent)
        updateTipLabel()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        guard let view = Bundle.main.loadNibNamed("FilterDistanceSlider", owner: self, options: nil)?.first as? UIView else {
            return
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layout(with: self).fill()
        
        tipTopBackground.layer.cornerRadius = floor(tipTopBackground.frame.size.height / 2)
        slider.maximumValue = Float(positions.count-1)
        slider.minimumValue = 0.0
        
        for i in 0..<positions.count {
            let percent = Float(i) / Float(positions.count - 1)
            let xPos = sliderCenterPosition(percent)
            let xPercent = xPos / marksContainerSize.width
            
            let markView = UIView()
            markView.backgroundColor = UIColor.grayText
            markView.translatesAutoresizingMaskIntoConstraints = false
            marksContainer.addSubview(markView)
            marksContainer.layout(with: markView)
                .trailing(to: .centerX, multiplier: 1 / xPercent)
                .top()
            markView.layout()
                .width(1)
                .height(marksContainerSize.height)
        }
    }
    
    // Resets the UI to the initial state
    func resetUI() {
        distanceLabel.text = ""
        updateTipPosition(0)
    }
    
    private func setAccessibilityIds() {
        slider.accessibilityId = .filterDistanceSlider
        distanceTip.accessibilityId = .filterDistanceTip
        distanceLabel.accessibilityId = .filterDistanceLabel
    }
    
    private func setupInPosition(_ position: Int) {
        slider.setValue(Float(position), animated: true)
        let percent = slider.value / slider.maximumValue
        updateTipPosition(percent)
        updateTipLabel()
    }
    
    private func updateTipPosition(_ percentage: Float) {
        distanceTipCenter.constant = sliderCenterPosition(percentage)
    }
    
    private func sliderCenterPosition(_ percentage: Float) -> CGFloat {
        return ((marksContainerSize.width - FilterDistanceSlider.sliderButtonSize)
            * CGFloat(percentage))
            + FilterDistanceSlider.sliderButtonSize / 2
    }
    
    private func updateTipLabel() {
        let currDist = distance
        if (currDist == positions.first) { // 0: distance "not set"
            distanceLabel.text = LGLocalizedString.filtersDistanceNotSet
        } else if (currDist == positions.last) { // 100: distance "max"
            distanceLabel.text = LGLocalizedString.commonMax
        } else {
            distanceLabel.text = "\(distance) \(distanceType.string)"
        }
    }
}
