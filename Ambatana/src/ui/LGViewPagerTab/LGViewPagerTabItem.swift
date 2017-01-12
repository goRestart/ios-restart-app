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
    private static let defaultIndicatorSelectedColor = UIColor.red
    private static let defaultInfoBadgeColor = UIColor.red
    private static let infoBadgeDiameter: CGFloat = 6

    // UI
    private var indicator: UIView
    private var infoBadge: UIView

    // UI setup
    var unselectedTitle: NSAttributedString = NSAttributedString() {
        didSet {
            setAttributedTitle(unselectedTitle, for: .normal)
        }
    }

    var selectedTitle: NSAttributedString = NSAttributedString() {
        didSet {
            setAttributedTitle(selectedTitle, for: .selected)
            setAttributedTitle(selectedTitle, for: .highlighted)
        }
    }

    var showInfoBadge: Bool {
        get {
            return !infoBadge.isHidden
        }
        set {
            infoBadge.isHidden = !newValue
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
            indicator.backgroundColor = isSelected ? indicatorSelectedColor : UIColor.clear
        }
    }

    override var isSelected: Bool {
        didSet {
            indicator.backgroundColor = isSelected ? indicatorSelectedColor : UIColor.clear
        }
    }


    // MARK: - Lifecycle

    init(indicatorHeight: CGFloat) {
        self.indicator = UIView()
        self.infoBadge = UIView()
        self.indicatorSelectedColor = LGViewPagerTabItem.defaultIndicatorSelectedColor
        super.init(frame: CGRect.zero)

        setupUI(indicatorHeight)
        setupConstraints(indicatorHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private methods

    private func setupUI(_ indicatorHeight: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8 + indicatorHeight, right: 16)
        backgroundColor = UIColor.clear
        setAttributedTitle(unselectedTitle, for: .normal)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        infoBadge.layer.cornerRadius = LGViewPagerTabItem.infoBadgeDiameter / 2
        infoBadge.translatesAutoresizingMaskIntoConstraints = false
        infoBadge.backgroundColor = LGViewPagerTabItem.defaultInfoBadgeColor
        addSubview(infoBadge)
    }

    private func setupConstraints(_ indicatorHeight: CGFloat) {
        setupIndicatorConstraints(indicatorHeight)
        setupInfoBadgeConstraints()
    }

    private func setupIndicatorConstraints(_ indicatorHeight: CGFloat) {
        var views = [String: Any]()
        views["indicator"] = indicator
        var metrics = [String: Any]()
        metrics["hIndicator"] = indicatorHeight

        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator(hIndicator)]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        addConstraints(vConstraints)

        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        addConstraints(hConstraints)
    }

    private func setupInfoBadgeConstraints() {
        let width = NSLayoutConstraint(item: infoBadge, attribute: .width, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1.0, constant: LGViewPagerTabItem.infoBadgeDiameter)
        let height = NSLayoutConstraint(item: infoBadge, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1.0, constant: LGViewPagerTabItem.infoBadgeDiameter)
        infoBadge.addConstraints([width,height])

        let left = NSLayoutConstraint(item: infoBadge, attribute: .left, relatedBy: .equal, toItem: titleLabel,
            attribute: .right, multiplier: 1.0, constant: 2)
        let center = NSLayoutConstraint(item: infoBadge, attribute: .centerY, relatedBy: .equal, toItem: titleLabel,
            attribute: .top, multiplier: 1.0, constant: 3)
        addConstraints([left,center])
    }
}
