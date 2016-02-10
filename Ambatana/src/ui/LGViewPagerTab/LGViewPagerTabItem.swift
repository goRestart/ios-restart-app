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

    // UI
    private var indicator: UIView

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
    }

    private func setupConstraints(indicatorHeight: CGFloat) {
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
}
