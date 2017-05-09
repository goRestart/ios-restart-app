//
//  NHRangeSliderView.swift
//  NHRangeSlider
//
//  Created by Hung on 17/12/16.
//  Copyright © 2016 Hung. All rights reserved.
//

import UIKit

/// enum for label positions
public enum NHSliderLabelStyle : Int {
    /// lower and upper labels stick to the left and right of slider
    case STICKY
    
    /// lower and upper labels follow position of lower and upper thumbs
    case FOLLOW
}

/// delegate for changed value
public protocol NHRangeSliderViewDelegate: class {
    /// slider value changed
    func sliderValueChanged(lowerValue: Double, upperValue: Double)
}


/// Range slider with labels for upper and lower thumbs, title label and configurable step value (optional)
open class NHRangeSliderView: UIView {

    //MARK: properties
    
    open var delegate: NHRangeSliderViewDelegate? = nil
    
    /// Range slider
    open var rangeSlider : NHRangeSlider? = nil

    /// vertical spacing
    open var spacing: CGFloat = 4.0
    
    /// position of thumb labels. Set to STICKY to stick to left and right positions. Set to FOLLOW to follow left and right thumbs
    open var thumbLabelStyle: NHSliderLabelStyle = .STICKY
    
    /// minimum value
    @IBInspectable open var minimumValue: Double = 0.0 {
        didSet {
            self.rangeSlider?.minimumValue = minimumValue
        }
    }
    
    /// max value
    @IBInspectable open var maximumValue: Double = 100.0 {
        didSet {
            self.rangeSlider?.maximumValue = maximumValue
        }
    }
    
    /// value for lower thumb
    @IBInspectable open var lowerValue: Double = 0.0 {
        didSet {
            self.rangeSlider?.lowerValue = lowerValue
        }
    }
    
    /// value for upper thumb
    @IBInspectable open var upperValue: Double = 100.0 {
        didSet {
            self.rangeSlider?.upperValue = upperValue
        }
    }
    
    /// stepValue. If set, will snap to discrete step points along the slider . Default to nil
    @IBInspectable open var stepValue: Double? = nil {
        didSet {
            self.rangeSlider?.stepValue = stepValue
        }
    }
    
    /// minimum distance between the upper and lower thumbs.
    open var gapBetweenThumbs: Double = 2.0 {
        didSet {
            self.rangeSlider?.gapBetweenThumbs = gapBetweenThumbs
        }
    }
    
    /// tint color for track between 2 thumbs
    @IBInspectable open var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            self.rangeSlider?.trackTintColor = trackTintColor
        }
    }
    
    
    /// track highlight tint color
    @IBInspectable open var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            self.rangeSlider?.trackHighlightTintColor = trackHighlightTintColor
        }
    }
    
    
    /// thumb tint color
    @IBInspectable open var thumbTintColor: UIColor = UIColor.white {
        didSet {
            self.rangeSlider?.thumbTintColor = thumbTintColor
        }
    }
    
    /// thumb border color
    @IBInspectable open var thumbBorderColor: UIColor = UIColor.gray {
        didSet {
            self.rangeSlider?.thumbBorderColor = thumbBorderColor
        }
    }
    
    
    /// thumb border width
    @IBInspectable open var thumbBorderWidth: CGFloat = 0.5 {
        didSet {
            self.rangeSlider?.thumbBorderWidth = thumbBorderWidth

        }
    }
    
    /// set 0.0 for square thumbs to 1.0 for circle thumbs
    @IBInspectable open var curvaceousness: CGFloat = 1.0 {
        didSet {
            self.rangeSlider?.curvaceousness = curvaceousness
        }
    }
    
    /// thumb width and height
    @IBInspectable open var thumbSize: CGFloat = 32.0 {
        didSet {
            if let slider = self.rangeSlider {
                var oldFrame = slider.frame
                oldFrame.size.height = thumbSize
                slider.frame = oldFrame
            }
        }
    }
    
    //MARK: init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    /// setup
    open func setup() {
        self.rangeSlider = NHRangeSlider(frame: .zero)
        self.rangeSlider?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.rangeSlider!)
        rangeSlider?.layout(with: self).fill()

        self.rangeSlider?.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
    }
    
    //MARK: range slider delegage
    
    /// Range slider change events. Upper / lower labels will be updated accordingly.
    /// Selected value for filterItem will also be updated
    ///
    /// - Parameter rangeSlider: the changed rangeSlider
    open func rangeSliderValueChanged(_ rangeSlider: NHRangeSlider) {
        delegate?.sliderValueChanged(lowerValue: rangeSlider.lowerValue, upperValue: rangeSlider.upperValue)
    }
}
