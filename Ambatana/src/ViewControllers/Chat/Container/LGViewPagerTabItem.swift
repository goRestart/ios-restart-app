//
//  LGViewPagerTabItem.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class LGViewPagerTabItem: UIButton {

    var indicator: UIView

    override var selected: Bool {
        didSet {
            indicator.backgroundColor = selected ? StyleHelper.primaryColor : UIColor.clearColor()
        }
    }

    init(selectedTitle: NSAttributedString, unselectedTitle: NSAttributedString, indicatorHeight: CGFloat) {
        self.indicator = UIView()
        super.init(frame: CGRectZero)

        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8 + indicatorHeight, right: 16)
        backgroundColor = UIColor.clearColor()
        setAttributedTitle(unselectedTitle, forState: .Normal)
        setAttributedTitle(selectedTitle, forState: .Selected)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)

        setupUI()
        setupConstraints(indicatorHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        indicator.backgroundColor = UIColor.purpleColor()
    }

    func setupConstraints(indicatorHeight: CGFloat) {
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

//    let item = LGViewPagerTabItem(type: .Custom)

//    return item

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
}
