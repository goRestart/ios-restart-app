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
    private static let defaultInfoIndicatorColor = UIColor.redColor()
    private static let infoIndicatorDiameter: CGFloat = 6

    // UI
    private var indicator: UIView
    private var infoIndicator: UIView

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

    var showInfoIndicator: Bool {
        get {
            return !infoIndicator.hidden
        }
        set {
            infoIndicator.hidden = !newValue
        }
    }

    var infoIndicatorColor: UIColor? {
        get {
            return infoIndicator.backgroundColor
        }
        set {
            infoIndicator.backgroundColor = newValue
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
        self.infoIndicator = UIView()
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
        infoIndicator.layer.cornerRadius = LGViewPagerTabItem.infoIndicatorDiameter / 2
        infoIndicator.translatesAutoresizingMaskIntoConstraints = false
        infoIndicator.backgroundColor = LGViewPagerTabItem.defaultInfoIndicatorColor
        addSubview(infoIndicator)
    }

    private func setupConstraints(indicatorHeight: CGFloat) {
        setupIndicatorConstraints(indicatorHeight)
        setupInfoIndicatorConstraints()
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

    private func setupInfoIndicatorConstraints() {
        let width = NSLayoutConstraint(item: infoIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1.0, constant: LGViewPagerTabItem.infoIndicatorDiameter)
        let height = NSLayoutConstraint(item: infoIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1.0, constant: LGViewPagerTabItem.infoIndicatorDiameter)
        infoIndicator.addConstraints([width,height])

        let left = NSLayoutConstraint(item: infoIndicator, attribute: .Left, relatedBy: .Equal, toItem: titleLabel,
            attribute: .Right, multiplier: 1.0, constant: 2)
        let center = NSLayoutConstraint(item: infoIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel,
            attribute: .Top, multiplier: 1.0, constant: 3)
        addConstraints([left,center])
    }
}
