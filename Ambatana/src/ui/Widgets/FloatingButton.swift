//
//  FloatingButton.swift
//  LetGo
//
//  Created by Albert Hernández López on 17/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class FloatingButton: UIView {
    private static let height: CGFloat = 50
    private let containerView: UIView
    let sellButton: UIButton

    var sellCompletion: (() -> ())?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        self.containerView = UIView()
        self.sellButton = UIButton(type: .Custom)

        super.init(frame: frame)

        setupConstraints()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = height / 2
    }


    // MARK: - Private methods

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sellButton)

        let containerViews: [String: AnyObject] = ["c": containerView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[c]-0-|", options: [],
                                                                      metrics: nil, views: containerViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[c]-0-|", options: [],
                                                                      metrics: nil, views: containerViews))

        let metrics: [String: AnyObject] = ["h": FloatingButton.height]
        let views: [String: AnyObject] = ["sb": sellButton]
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sb(h)]-0-|", options: [],
                                                                                    metrics: metrics, views: views))

        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[sb]-0-|", options: [],
                                                                          metrics: nil, views: views)
        containerView.addConstraints(hConstraints)
    }

    private func setupUI() {
        applyFloatingButtonShadow()
        containerView.clipsToBounds = true

        let titleIconSpacing: CGFloat = 10
        let extraPadding: CGFloat = 6
        sellButton.setTitle(LGLocalizedString.tabBarToolTip, forState: .Normal)
        let sellButtonImage = UIImage(named: "ic_sell_white")
        sellButton.setImage(sellButtonImage, forState: .Normal)
        sellButton.setImage(sellButtonImage, forState: .Highlighted)
        sellButton.titleLabel?.font = UIFont.bigButtonFont
        sellButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: titleIconSpacing, bottom: 0, right: -titleIconSpacing)
        sellButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2*extraPadding, bottom: 0, right: 2*extraPadding+titleIconSpacing)
        sellButton.setTitleColor(UIColor.white, forState: .Normal)
        sellButton.setBackgroundImage(UIColor.primaryColor.imageWithSize(CGSize(width: 1, height: 1)),
                                      forState: .Normal)
        sellButton.setBackgroundImage(UIColor.primaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                                      forState: .Highlighted)
        sellButton.setBackgroundImage(UIColor.primaryColorDisabled.imageWithSize(CGSize(width: 1, height: 1)),
                                      forState: .Disabled)
        sellButton.addTarget(self, action: #selector(runSellCompletion), forControlEvents: .TouchUpInside)
    }

    private dynamic func runSellCompletion() {
        sellCompletion?()
    }
}
