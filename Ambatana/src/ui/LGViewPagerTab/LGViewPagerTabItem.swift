//
//  LGViewPagerTabItem.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class LGViewPagerTabItem: UIButton {

    // Constants
    private static let defaultIndicatorSelectedColor = UIColor.redColor()
    private static let defaultInfoBadgeColor = UIColor.redColor()
    private static let infoBadgeDiameter: CGFloat = 6

    // UI
    private var indicator: UIView
    private var infoBadge: UIView

    // UI setup
    var unselectedTitle: NSAttributedString = NSAttributedString() {
        didSet {
            setAttributedTitle(unselectedTitle, forState: .Normal)
        }
    }

    var selectedTitle: NSAttributedString = NSAttributedString() {
        didSet {
            setAttributedTitle(selectedTitle, forState: .Selected)
            setAttributedTitle(selectedTitle, forState: .Highlighted)
        }
    }

    var showInfoBadge: Bool {
        get {
            return !infoBadge.hidden
        }
        set {
            infoBadge.hidden = !newValue
        }
    }

    var infoBadgeColor: UIColor? {
        get {
            return infoBadge.backgroundColor
        }
        set {
            infoBadge.backgroundColor = newValue
        }
    }

    var indicatorSelectedColor: UIColor {
        didSet {
            indicator.backgroundColor = selected ? indicatorSelectedColor : UIColor.clearColor()
        }
    }

    override var selected: Bool {
        didSet {
            indicator.backgroundColor = selected ? indicatorSelectedColor : UIColor.clearColor()
        }
    }


    // MARK: - Lifecycle

    init(indicatorHeight: CGFloat) {
        self.indicator = UIView()
        self.infoBadge = UIView()
        self.indicatorSelectedColor = LGViewPagerTabItem.defaultIndicatorSelectedColor
        super.init(frame: CGRectZero)

        setupUI(indicatorHeight)
        setupConstraints(indicatorHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private methods

    private func setupUI(indicatorHeight: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8 + indicatorHeight, right: 16)
        backgroundColor = UIColor.clearColor()
        setAttributedTitle(unselectedTitle, forState: .Normal)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        infoBadge.layer.cornerRadius = LGViewPagerTabItem.infoBadgeDiameter / 2
        infoBadge.translatesAutoresizingMaskIntoConstraints = false
        infoBadge.backgroundColor = LGViewPagerTabItem.defaultInfoBadgeColor
        addSubview(infoBadge)
    }

    private func setupConstraints(indicatorHeight: CGFloat) {
        setupIndicatorConstraints(indicatorHeight)
        setupInfoBadgeConstraints()
    }

    private func setupIndicatorConstraints(indicatorHeight: CGFloat) {
        var views = [String: AnyObject]()
        views["indicator"] = indicator
        var metrics = [String: AnyObject]()
        metrics["hIndicator"] = indicatorHeight

        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator(hIndicator)]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        addConstraints(vConstraints)

        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[indicator]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        addConstraints(hConstraints)
    }

    private func setupInfoBadgeConstraints() {
        let width = NSLayoutConstraint(item: infoBadge, attribute: .Width, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1.0, constant: LGViewPagerTabItem.infoBadgeDiameter)
        let height = NSLayoutConstraint(item: infoBadge, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1.0, constant: LGViewPagerTabItem.infoBadgeDiameter)
        infoBadge.addConstraints([width,height])

        let left = NSLayoutConstraint(item: infoBadge, attribute: .Left, relatedBy: .Equal, toItem: titleLabel,
            attribute: .Right, multiplier: 1.0, constant: 2)
        let center = NSLayoutConstraint(item: infoBadge, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel,
            attribute: .Top, multiplier: 1.0, constant: 3)
        addConstraints([left,center])
    }
}
