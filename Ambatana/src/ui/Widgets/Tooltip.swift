//
//  Tooltip.swift
//  LetGo
//
//  Created by Dídac on 15/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

public enum TooltipStyle {
    case Black
    case Blue

    var bgColor: UIColor {
        switch self {
        case .Black:
            return UIColor.blackTooltip.colorWithAlphaComponent(0.95)
        case .Blue:
            return UIColor.blueTooltip.colorWithAlphaComponent(0.95)
        }
    }

    var centeredPeak: UIImage? {
        switch self {
        case .Black:
            return UIImage(named: "tooltip_peak_center_black")
        case .Blue:
            return UIImage(named: "tooltip_peak_center_blue")
        }
    }

    var leftSidePeak: UIImage? {
        switch self {
        case .Black:
            return UIImage(named: "tooltip_peak_side_black")
        case .Blue:
            return UIImage(named: "tooltip_peak_side_blue")
        }
    }

    var rightSidePeak: UIImage? {
        switch self {
        case .Black:
            guard let originalImg = UIImage(named: "tooltip_peak_side_black"), cgImg = originalImg.CGImage else { return nil }
            return UIImage.init(CGImage: cgImg, scale: originalImg.scale, orientation: .UpMirrored)
        case .Blue:
            guard let originalImg = UIImage(named: "tooltip_peak_side_blue"), cgImg = originalImg.CGImage else { return nil }
            return UIImage.init(CGImage: cgImg, scale: originalImg.scale, orientation: .UpMirrored)
        }
    }
}

public class Tooltip: UIView {

    static var minSideMarginToSuperview: CGFloat = 8

    var coloredView: UIView!
    var titleLabel: UILabel!
    var closeButton: UIButton!
    var separationView: UIView!
    var downTooltipPeak: UIImageView!
    var upTooltipPeak: UIImageView!

    var downPeakCenterConstraint: NSLayoutConstraint!
    var upPeakCenterConstraint: NSLayoutConstraint!

    var targetView: UIView = UIView()
    var targetGlobalCenter: CGPoint = CGPointZero
    var superView: UIView = UIView()
    var title: NSAttributedString = NSAttributedString()
    var style: TooltipStyle = .Black
    var tooltipOffset: CGFloat = 0.0
    var peakOffset: CGFloat = 0.0
    var actionBlock: ()->() = {}

    var superViewWidth: CGFloat {
        return superView.width
    }
    private var peakOnTop: Bool = false


    // MARK: Lifecycle

    /**
     Initializes a tooltip
     
     - parameter targetView: the view that will have the related tooltip
     - parameter superView: the view where the tooltip will be added
     - parameter title: text of the tooltip
     - parameter style: style of the tooltip (Black or Blue)
     - parameter tooltipOffset: the offset of the whole tooltip, if needed
     - parameter peakOnTop: true if the peak of the tooltip should go over it (tooltip will be shown UNDER targetView)
     - parameter peakOffset: the offset of the peak of the tooltip (in case the target view is to far to a side)
     - parameter actionBlock: the action executed when the text is tapped
     */

    convenience init(targetView: UIView, superView: UIView, title: NSAttributedString, style: TooltipStyle, tooltipOffset: CGFloat?, peakOnTop: Bool, peakOffset: CGFloat?, actionBlock: () -> ()) {
        self.init(frame: CGRectMake(0, 0, 270, 70))

        self.title = title
        self.targetView = targetView
        self.targetGlobalCenter = superView.convertPoint(targetView.center, toView: nil)
        self.superView = superView
        self.style = style
        self.tooltipOffset = tooltipOffset ?? 0.0
        self.peakOnTop = peakOnTop
        self.peakOffset = peakOffset ?? 0.0
        self.actionBlock = actionBlock

        setupUI()
    }

    override init(frame: CGRect)  {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    // MARK: - public methods

    public func setupExternalConstraints() {
        let leftSideMain = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: superView, attribute: .Left, multiplier: 1, constant: 8)
        leftSideMain.priority = 999
        let rightSideMain = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: superView, attribute: .Left, multiplier: 1, constant: -8)
        rightSideMain.priority = 999
        superView.addConstraints([leftSideMain, rightSideMain])

        let mainTopConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: targetView, attribute: .Bottom, multiplier: 1, constant: 0)
        let mainBottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: targetView, attribute: .Top, multiplier: 1, constant: 0)
        peakOnTop ? superView.addConstraints([mainTopConstraint]) : superView.addConstraints([mainBottomConstraint])

        let mainLeftConstraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: targetView, attribute: .Left, multiplier: 1, constant: tooltipOffset)
        mainLeftConstraint.priority = 998
        let mainRightConstraint = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: targetView, attribute: .Right, multiplier: 1, constant: tooltipOffset)
        mainRightConstraint.priority = 998
        let mainCenterConstraint = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: targetView, attribute: .CenterX, multiplier: 1, constant: tooltipOffset)
        mainRightConstraint.priority = 998

        if targetGlobalCenter.x < superView.width/3 {
            // target in left
            superView.addConstraints([mainLeftConstraint])
        } else if targetGlobalCenter.x > (superView.width/3)*2 {
            // target in right
            superView.addConstraints([mainRightConstraint])
        } else {
            // target in center
            superView.addConstraints([mainCenterConstraint])
        }
    }


    // MARK: private methods

    public func setupUI() {

        translatesAutoresizingMaskIntoConstraints = false

        coloredView = UIView()
        coloredView.translatesAutoresizingMaskIntoConstraints = false
        coloredView.layer.cornerRadius = StyleHelper.productOnboardingTipsCornerRadius
        coloredView.backgroundColor = style.bgColor
        addSubview(coloredView)

        titleLabel = UILabel()
        titleLabel.attributedText = title
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let tapTitle = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        titleLabel.addGestureRecognizer(tapTitle)
        titleLabel.userInteractionEnabled = true
        coloredView.addSubview(titleLabel)

        separationView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 28))
        separationView.backgroundColor = UIColor.white
        separationView.translatesAutoresizingMaskIntoConstraints = false
        coloredView.addSubview(separationView)

        closeButton = UIButton()
        closeButton.setImage(UIImage(named: "ic_close"), forState: .Normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTooltip), forControlEvents: .TouchUpInside)
        coloredView.addSubview(closeButton)

        upTooltipPeak = UIImageView(image: style.centeredPeak?.upsideDownImage())
        upTooltipPeak.translatesAutoresizingMaskIntoConstraints = false
        addSubview(upTooltipPeak)
        downTooltipPeak = UIImageView(image: style.centeredPeak)
        downTooltipPeak.translatesAutoresizingMaskIntoConstraints = false
        addSubview(downTooltipPeak)
        setupPeak()

        setupConstraints()
    }

    private func setupConstraints() {

        // self
        let mainWidth = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 270)
        mainWidth.priority = 999
        let mainHeight = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70)
        mainHeight.priority = 999
        self.addConstraints([mainWidth, mainHeight])

        // colored view
        let coloredViewTop = NSLayoutConstraint(item: coloredView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10)
        let coloredViewBottom = NSLayoutConstraint(item: coloredView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -10)
        let coloredViewLeft = NSLayoutConstraint(item: coloredView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let coloredViewRight = NSLayoutConstraint(item: coloredView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        self.addConstraints([coloredViewTop, coloredViewBottom, coloredViewLeft, coloredViewRight])

        // title label
        let labelTop = NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: coloredView, attribute: .Top, multiplier: 1, constant: 15)
        let labelBottom = NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: coloredView, attribute: .Bottom, multiplier: 1, constant: -15)
        let labelLeft = NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: coloredView, attribute: .Left, multiplier: 1, constant: 12)
        let labelRight = NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: separationView, attribute: .Left, multiplier: 1, constant: -12)
        coloredView.addConstraints([labelTop, labelBottom, labelLeft, labelRight])

        // separation view
        let separationViewHeight = NSLayoutConstraint(item: separationView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 28)
        let separationViewWidth = NSLayoutConstraint(item: separationView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1)
        separationView.addConstraints([separationViewHeight, separationViewWidth])

        let separationViewRight = NSLayoutConstraint(item: separationView, attribute: .Right, relatedBy: .Equal, toItem: closeButton, attribute: .Left, multiplier: 1, constant: -19)
        let separationViewCenterY = NSLayoutConstraint(item: separationView, attribute: .CenterY, relatedBy: .Equal, toItem: coloredView, attribute: .CenterY, multiplier: 1, constant: 0)
        coloredView.addConstraints([separationViewRight, separationViewCenterY])

        // close button
        let closeButtonHeight = NSLayoutConstraint(item: closeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 18)
        let closeButtonWidth = NSLayoutConstraint(item: closeButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 18)
        closeButton.addConstraints([closeButtonHeight, closeButtonWidth])

        let closeButtonRight = NSLayoutConstraint(item: closeButton, attribute: .Right, relatedBy: .Equal, toItem: coloredView, attribute: .Right, multiplier: 1, constant: -19)
        let closeButtonCenterY = NSLayoutConstraint(item: closeButton, attribute: .CenterY, relatedBy: .Equal, toItem: coloredView, attribute: .CenterY, multiplier: 1, constant: 0)
        coloredView.addConstraints([closeButtonRight, closeButtonCenterY])

        setupConstraintsForPeakOnTop()
        setupConstraintsForPeakOnBottom()

        layoutIfNeeded()
    }

    private func setupConstraintsForPeakOnTop() {
        let width = NSLayoutConstraint(item: upTooltipPeak, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15)
        upTooltipPeak.addConstraints([width])

        let top = NSLayoutConstraint(item: upTooltipPeak, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: upTooltipPeak, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: peakOffset)
        let bottom = NSLayoutConstraint(item: upTooltipPeak, attribute: .Bottom, relatedBy: .Equal, toItem: coloredView, attribute: .Top, multiplier: 1, constant: 0)

        self.addConstraints([top, centerX, bottom])
    }

    private func setupConstraintsForPeakOnBottom() {
        let width = NSLayoutConstraint(item: downTooltipPeak, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15)
        downTooltipPeak.addConstraints([width])

        let top = NSLayoutConstraint(item: downTooltipPeak, attribute: .Top, relatedBy: .Equal, toItem: coloredView, attribute: .Bottom, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: downTooltipPeak, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: peakOffset)
        let bottom = NSLayoutConstraint(item: downTooltipPeak, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)

        self.addConstraints([top, centerX, bottom])
    }

    private func setupPeak() {
        downTooltipPeak.hidden = peakOnTop   // target view is too up, peak goes up
        upTooltipPeak.hidden = !(peakOnTop)  // peak goes down

        // Screen divided in 3 parts to decide what kind of peak must be shown
        if targetView.center.x < superViewWidth/3 {
            // target view is on the left
            downTooltipPeak.image = style.leftSidePeak
            upTooltipPeak.image = style.leftSidePeak?.upsideDownImage()
        } else if targetView.center.x > (superViewWidth/3)*2 {
            // target view is on the right
            downTooltipPeak.image = style.rightSidePeak
            upTooltipPeak.image = style.rightSidePeak?.upsideDownImage()
        } else {
            // target view is on the center
            downTooltipPeak.image = style.centeredPeak
            upTooltipPeak.image = style.centeredPeak?.upsideDownImage()
        }
    }

    dynamic func titleTapped() {
        actionBlock()
        removeFromSuperview()
    }

    dynamic func closeTooltip() {
        removeFromSuperview()
    }
}
