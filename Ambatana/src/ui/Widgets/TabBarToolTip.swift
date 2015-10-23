//
//  TabBarToolTip.swift
//  LetGo
//
//  Created by Albert Hernández López on 26/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

public class TabBarToolTip: UIView {

    // Constants
    private static let boxHeight: CGFloat = 44
    private static let labelMargins: CGFloat = 20
    
    // UI
    private var boxButton: UIButton
    private var label: UILabel
    private var arrowImageView: UIImageView
    
    // Data
    public var text: String {
        get {
            return label.text ?? ""
        }
        set {
            label.text = newValue
        }
    }
    
    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        let f = CGRectMake(0, 0, frame.size.width, frame.size.height)
        boxButton = UIButton(frame: f)
        label = UILabel(frame: f)
        arrowImageView = UIImageView(image: UIImage(named: "arrow_tooltip"))
        super.init(frame: frame)
        
        setupUI()
        setupLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        frame.size = intrinsicContentSize()
    }
    
    override public func intrinsicContentSize() -> CGSize {
        var size = frame.size
        // Label is limited by superview's width
        if let actualSuperview = superview {
            let maxLabelSize = CGSize(width: actualSuperview.frame.size.height - 2 * TabBarToolTip.labelMargins, height: label.frame.height)
            size = CGSize(width: label.sizeThatFits(maxLabelSize).width, height: TabBarToolTip.boxHeight + arrowImageView.image!.size.height)
        }
        return size
    }
    
    // MARK: - Public methods
    
    public func addTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        boxButton.addTarget(target, action: action, forControlEvents: controlEvents)
    }
    
    // MARK: - Private methods
    
    /**
        Sets up the UI.
    */
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        boxButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
    
        boxButton.addSubview(label)
        addSubview(boxButton)
        addSubview(arrowImageView)
        
        boxButton.layer.cornerRadius = TabBarToolTip.boxHeight/2
        boxButton.backgroundColor = StyleHelper.tabBarTooltipBgColor
        label.textColor = StyleHelper.tabBarTooltipTextColor
        label.font = StyleHelper.tabBarTooltipTextFont
    }

    /**
        Sets up the auto layout constraints.
    */
    private func setupLayout() {
        // Box: Full size horizontally, full size vertically with bottom margin (arrow height, againt self)
        let views = ["boxButton": boxButton]
        let metrics = ["height": TabBarToolTip.boxHeight, "bottom": CGRectGetHeight(arrowImageView.frame) - 1]  // -1: @ahl: Visual adjustment: when aligned a thin line flicks
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[boxButton(height)]-bottom-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[boxButton]|", options: [], metrics: nil, views: views))
        
        // Label: vertically aligned & with horizontal margins (against box)
        let boxViewViews = ["label": label]
        let boxViewMetrics = ["labelMargins": TabBarToolTip.labelMargins]
        boxButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-labelMargins-[label]-labelMargins-|", options: [], metrics: boxViewMetrics, views: boxViewViews))
        boxButton.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: label.superview, attribute: .CenterY, multiplier: 1, constant: 0))
        
        // Arrow: horizontally centered & aligned to bottom (againt self)
        addConstraint(NSLayoutConstraint(item: arrowImageView, attribute: .Bottom, relatedBy: .Equal, toItem: arrowImageView.superview, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: arrowImageView, attribute: .CenterX, relatedBy: .Equal, toItem: arrowImageView.superview, attribute: .CenterX, multiplier: 1, constant: 0))
    }
}
