//
//  Tooltip.swift
//  LetGo
//
//  Created by Dídac on 15/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

enum TooltipStyle {
    case black(closeEnabled: Bool)
    case blue(closeEnabled: Bool)

    static let minWidthWithCloseButton: CGFloat = 200
    static let minWidthWithoutCloseButton: CGFloat = 150

    var closeEnabled: Bool {
        switch self {
        case let .black(closeEnabled):
            return closeEnabled
        case let .blue(closeEnabled):
            return closeEnabled
        }
    }

    var bgColor: UIColor {
        switch self {
        case .black:
            return UIColor.blackTooltip.withAlphaComponent(0.95)
        case .blue:
            return UIColor.blueTooltip.withAlphaComponent(0.95)
        }
    }

    var centeredPeak: UIImage? {
        return UIImage(named: "tooltip_peak_center_black")?.withRenderingMode(.alwaysTemplate)
    }

    var leftSidePeak: UIImage? {
        return UIImage(named: "tooltip_peak_side_black")?.withRenderingMode(.alwaysTemplate)
    }

    var rightSidePeak: UIImage? {
        guard let originalImg = leftSidePeak, let cgImg = originalImg.cgImage else { return nil }
        return UIImage.init(cgImage: cgImg, scale: originalImg.scale, orientation: .upMirrored)
    }

    var minWidth: CGFloat {
        return closeEnabled ? TooltipStyle.minWidthWithCloseButton : TooltipStyle.minWidthWithoutCloseButton
    }
}

class Tooltip: UIView {

    static var peakViewCenterDistance: CGFloat = 8

    var coloredView: UIView = UIView()
    var titleLabel: UILabel = UILabel()
    var closeButton: UIButton = UIButton()
    var separationView: UIView = UIView()
    var downTooltipPeak: UIImageView = UIImageView()
    var upTooltipPeak: UIImageView = UIImageView()

    var targetView: UIView = UIView()
    var targetGlobalCenter: CGPoint = CGPoint.zero
    var superView: UIView = UIView()
    var title: NSAttributedString = NSAttributedString()
    var style: TooltipStyle = .black(closeEnabled: true)
    var actionBlock: ()->() = {}
    var closeBlock: (()->())?

    var peakOffset: CGFloat = 0.0 {
        didSet {
            setupConstraintsForPeakOnBottom()
            setupConstraintsForPeakOnTop()
        }
    }

    var superViewWidth: CGFloat {
        return superView.width
    }

    var peakOnTop: Bool = false


    // MARK: Lifecycle

    /**
     Initializes a tooltip
     
     - parameter targetView: the view that will have the related tooltip
     - parameter superView: the view where the tooltip will be added
     - parameter title: text of the tooltip
     - parameter style: style of the tooltip (Black or Blue)
     - parameter peakOnTop: true if the peak of the tooltip should go over it (tooltip will be shown UNDER targetView)
     - parameter actionBlock: the action executed when the text is tapped
     */

    convenience init(targetView: UIView, superView: UIView, title: NSAttributedString, style: TooltipStyle,
                     peakOnTop: Bool, actionBlock: @escaping () -> (), closeBlock: (() -> ())?) {
        self.init()

        self.title = title
        self.targetView = targetView
        self.targetGlobalCenter = superView.convert(targetView.center, to: nil)
        self.superView = superView
        self.style = style
        self.peakOnTop = peakOnTop
        self.actionBlock = actionBlock
        self.closeBlock = closeBlock

        setupUI()
    }

    override init(frame: CGRect)  {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        targetGlobalCenter = superView.convert(targetView.center, to: nil)
        peakOffset = peakFinalOffset()
    }

    
    // MARK: private methods

    private func setupUI() {

        translatesAutoresizingMaskIntoConstraints = false

        coloredView.translatesAutoresizingMaskIntoConstraints = false
        coloredView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        coloredView.backgroundColor = style.bgColor
        addSubview(coloredView)

        titleLabel.attributedText = title
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let tapTitle = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        titleLabel.addGestureRecognizer(tapTitle)
        titleLabel.isUserInteractionEnabled = true
        coloredView.addSubview(titleLabel)

        if style.closeEnabled {
            separationView.frame = CGRect(x: 0, y: 0, width: 2, height: 28)
            separationView.backgroundColor = .white
            separationView.translatesAutoresizingMaskIntoConstraints = false
            coloredView.addSubview(separationView)

            closeButton.setImage(UIImage(named: "ic_close"), for: .normal)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.addTarget(self, action: #selector(closeTooltip), for: .touchUpInside)
            coloredView.addSubview(closeButton)
        }

        upTooltipPeak.translatesAutoresizingMaskIntoConstraints = false
        addSubview(upTooltipPeak)

        downTooltipPeak.translatesAutoresizingMaskIntoConstraints = false
        addSubview(downTooltipPeak)
        setupPeak()

        setupConstraints()
    }

    private func setupConstraints() {

        // self
        let mainWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 270)
        mainWidth.priority = .required - 1
        let mainMinWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: style.minWidth)
        mainMinWidth.priority = .required - 1

        let mainHeight = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70)
        mainHeight.priority = .required - 1
        self.addConstraints([mainWidth, mainMinWidth, mainHeight])

        // colored view
        let coloredViewTop = NSLayoutConstraint(item: coloredView, attribute: .top, relatedBy: .equal,
                                                toItem: self, attribute: .top, multiplier: 1, constant: 10)
        let coloredViewBottom = NSLayoutConstraint(item: coloredView, attribute: .bottom, relatedBy: .equal,
                                                   toItem: self, attribute: .bottom, multiplier: 1, constant: -10)
        let coloredViewLeft = NSLayoutConstraint(item: coloredView, attribute: .left, relatedBy: .equal,
                                                 toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let coloredViewRight = NSLayoutConstraint(item: coloredView, attribute: .right, relatedBy: .equal,
                                                  toItem: self, attribute: .right, multiplier: 1, constant: 0)
        self.addConstraints([coloredViewTop, coloredViewBottom, coloredViewLeft, coloredViewRight])

        // title label
        let labelTop = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                                          toItem: coloredView, attribute: .top, multiplier: 1, constant: Metrics.shortMargin)
        let labelBottom = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal,
                                             toItem: coloredView, attribute: .bottom, multiplier: 1, constant: -Metrics.shortMargin)
        let labelLeft = NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                                           toItem: coloredView, attribute: .left, multiplier: 1, constant: Metrics.margin)
        if style.closeEnabled {
            let labelRight = NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                                                toItem: separationView, attribute: .left, multiplier: 1, constant: -12)
            coloredView.addConstraints([labelTop, labelBottom, labelLeft, labelRight])

            // separation view
            let separationViewHeight = NSLayoutConstraint(item: separationView, attribute: .height, relatedBy: .equal,
                                                          toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28)
            let separationViewWidth = NSLayoutConstraint(item: separationView, attribute: .width, relatedBy: .equal,
                                                         toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
            separationView.addConstraints([separationViewHeight, separationViewWidth])

            let separationViewRight = NSLayoutConstraint(item: separationView, attribute: .right, relatedBy: .equal,
                                                         toItem: closeButton, attribute: .left, multiplier: 1, constant: 0)
            let separationViewCenterY = NSLayoutConstraint(item: separationView, attribute: .centerY, relatedBy: .equal,
                                                           toItem: coloredView, attribute: .centerY, multiplier: 1, constant: 0)
            coloredView.addConstraints([separationViewRight, separationViewCenterY])

            // close button
            let closeButtonHeight = NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            let closeButtonWidth = NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            closeButton.addConstraints([closeButtonHeight, closeButtonWidth])

            let closeButtonRight = NSLayoutConstraint(item: closeButton, attribute: .right, relatedBy: .equal,
                                                      toItem: coloredView, attribute: .right, multiplier: 1, constant: -8)
            let closeButtonCenterY = NSLayoutConstraint(item: closeButton, attribute: .centerY, relatedBy: .equal,
                                                        toItem: coloredView, attribute: .centerY, multiplier: 1, constant: 0)
            coloredView.addConstraints([closeButtonRight, closeButtonCenterY])
        } else {
            let labelRight = NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                                                toItem: coloredView, attribute: .right, multiplier: 1, constant: -12)
            coloredView.addConstraints([labelTop, labelBottom, labelLeft, labelRight])
        }
    }

    private func setupConstraintsForPeakOnTop() {
        let width = NSLayoutConstraint(item: upTooltipPeak, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15)
        upTooltipPeak.addConstraints([width])

        let top = NSLayoutConstraint(item: upTooltipPeak, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: upTooltipPeak, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: peakOffset)
        let bottom = NSLayoutConstraint(item: upTooltipPeak, attribute: .bottom, relatedBy: .equal, toItem: coloredView, attribute: .top, multiplier: 1, constant: 0)

        self.addConstraints([top, centerX, bottom])
    }

    private func setupConstraintsForPeakOnBottom() {
        let width = NSLayoutConstraint(item: downTooltipPeak, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15)
        downTooltipPeak.addConstraints([width])

        let top = NSLayoutConstraint(item: downTooltipPeak, attribute: .top, relatedBy: .equal, toItem: coloredView, attribute: .bottom, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: downTooltipPeak, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: peakOffset)
        let bottom = NSLayoutConstraint(item: downTooltipPeak, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)

        self.addConstraints([top, centerX, bottom])
    }

    private func setupPeak() {
        downTooltipPeak.isHidden = peakOnTop   // target view is too up, peak goes up
        upTooltipPeak.isHidden = !peakOnTop  // peak goes down
        
        // Screen divided in 3 parts to decide what kind of peak must be shown
        if targetGlobalCenter.x < superViewWidth/3 {
            // target view is on the left
            downTooltipPeak.image = style.leftSidePeak
            upTooltipPeak.image = style.leftSidePeak?.rotatedImage().rotatedImage().withRenderingMode(.alwaysTemplate)
        } else if targetGlobalCenter.x > (superViewWidth/3)*2 {
            // target view is on the right
            downTooltipPeak.image = style.rightSidePeak
            upTooltipPeak.image = style.rightSidePeak?.rotatedImage().rotatedImage().withRenderingMode(.alwaysTemplate)
        } else {
            // target view is on the center
            downTooltipPeak.image = style.centeredPeak
            upTooltipPeak.image = style.centeredPeak?.rotatedImage().rotatedImage().withRenderingMode(.alwaysTemplate)
        }
        
        downTooltipPeak.tintColor = style.bgColor
        upTooltipPeak.tintColor = style.bgColor

    }

    @objc func titleTapped() {
        actionBlock()
        removeFromSuperview()
    }

    @objc func closeTooltip() {
        closeBlock?()
        removeFromSuperview()
    }

    private func peakFinalOffset() -> CGFloat {
        let tmpPeakOffset = -(frame.origin.x+width/2-targetGlobalCenter.x)
        let maxOffset =  width/2-LGUIKitConstants.mediumCornerRadius-Tooltip.peakViewCenterDistance
        let minOffset =  -(width/2-LGUIKitConstants.mediumCornerRadius-Tooltip.peakViewCenterDistance)
        return max(min(tmpPeakOffset,maxOffset), minOffset)
    }
}


// MARK: global methods related to Tooltip

/**
 Positions the tooltip inside its superview

 - parameter tooltip: the tooltip where to apply the constraints
 - parameter targetView: the view that will have the related tooltip
 - parameter containerView: the view where the tooltip will be added
 */

func setupExternalConstraintsForTooltip(_ tooltip: Tooltip, targetView: UIView, containerView: UIView,
                                        margin: CGFloat = 0) {

    let targetGlobalCenter = containerView.convert(targetView.center, to: nil)
    
    let tooltipLeadingAnchor = tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 40)
    let tooltipTrailingAnchor =  tooltip.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -40)

    let peakAligment: NSLayoutConstraint
    if tooltip.peakOnTop {
        peakAligment = tooltip.topAnchor.constraint(equalTo: targetView.bottomAnchor, constant: margin)
        containerView.addConstraint(NSLayoutConstraint(item: tooltip, attribute: .top, relatedBy: .equal,
            toItem: targetView, attribute: .bottom, multiplier: 1, constant: margin))
    } else {
        peakAligment = tooltip.bottomAnchor.constraint(equalTo: targetView.topAnchor, constant: -margin)
    }

    let alignmentConstraint: NSLayoutConstraint

    if targetGlobalCenter.x < containerView.width/3 {
        alignmentConstraint = tooltip.leadingAnchor.constraint(equalTo: targetView.leadingAnchor)
    } else if targetGlobalCenter.x > (containerView.width/3)*2 {
        alignmentConstraint = tooltip.trailingAnchor.constraint(equalTo: targetView.trailingAnchor)
    } else {
        alignmentConstraint = tooltip.centerXAnchor.constraint(equalTo: targetView.centerXAnchor)
    }
    NSLayoutConstraint.activate([peakAligment, alignmentConstraint, tooltipLeadingAnchor, tooltipTrailingAnchor])
}
