//
//  FloatingButton.swift
//  LetGo
//
//  Created by Albert Hernández López on 17/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class FloatingButton: UIView {
    private let containerView: UIView
    private let sellButton: UIButton
    private let giveAwayButton: UIButton

    var sellCompletion: (() -> ())?
    var giveAwayCompletion: (() -> ())?


    // MARK: - Lifecycle

    convenience init() {
        self.init(freePostingMode: FeatureFlags.freePostingMode)
    }

    init(freePostingMode: FreePostingMode) {
        self.containerView = UIView()
        self.sellButton = UIButton(type: .Custom)
        self.giveAwayButton = UIButton(type: .Custom)

        super.init(frame: CGRect.zero)

        setupConstraints(freePostingMode)
        setupUI(freePostingMode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = CGRectGetHeight(frame) / 2
    }


    // MARK: - Private methods

    private func setupConstraints(freePostingMode: FreePostingMode) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sellButton)

        let containerViews: [String: AnyObject] = ["c": containerView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[c]-0-|", options: [],
                                                                      metrics: nil, views: containerViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[c]-0-|", options: [],
                                                                      metrics: nil, views: containerViews))

        let views: [String: AnyObject] = ["sb": sellButton, "gab": giveAwayButton]
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sb(50)]-0-|", options: [],
                                                                                    metrics: nil, views: views))

        let hConstraintsVF: String
        switch freePostingMode {
        case .Disabled, .OneButton:
            hConstraintsVF = "H:|-0-[sb]-0-|"

        case .SplitButton:
            giveAwayButton.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(giveAwayButton)

            hConstraintsVF = "H:|-0-[sb]-0-[gab]-0-|"
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[gab]-0-|", options: [],
                                                                                        metrics: nil, views: views))

            containerView.addConstraint(NSLayoutConstraint(item: sellButton, attribute: .Width, relatedBy: .Equal,
                                                           toItem: giveAwayButton, attribute: .Width,
                                                           multiplier: 1.0, constant: 0))
        }
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(hConstraintsVF, options: [],
                                                                          metrics: nil, views: views)
        containerView.addConstraints(hConstraints)
    }

    private func setupUI(freePostingMode: FreePostingMode) {
        applyFloatingButtonShadow()
        containerView.clipsToBounds = true

        let titleIconSpacing: CGFloat = 10
        let extraPadding: CGFloat = 10
        switch freePostingMode {
        case .Disabled, .OneButton:
            sellButton.setTitle(LGLocalizedString.tabBarToolTip, forState: .Normal)
            let sellButtonImage = UIImage(named: "ic_sell_white")
            sellButton.setImage(sellButtonImage, forState: .Normal)
            sellButton.setImage(sellButtonImage, forState: .Highlighted)
            sellButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: titleIconSpacing, bottom: 0, right: -titleIconSpacing)
            sellButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2*extraPadding, bottom: 0, right: 2*extraPadding+titleIconSpacing)
        case .SplitButton:
            sellButton.setTitle(LGLocalizedString.tabBarSellStuffButton, forState: .Normal)
            let sellButtonImage = UIImage(named: "ic_main_sell")
            sellButton.setImage(sellButtonImage, forState: .Normal)
            sellButton.setImage(sellButtonImage, forState: .Highlighted)
            sellButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: titleIconSpacing, bottom: 0, right: -titleIconSpacing)
            sellButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: extraPadding, bottom: 0, right: 2*titleIconSpacing)
        }
        sellButton.setTitleColor(UIColor.white, forState: .Normal)
        sellButton.setBackgroundImage(UIColor.primaryColor.imageWithSize(CGSize(width: 1, height: 1)),
                                      forState: .Normal)
        sellButton.setBackgroundImage(UIColor.primaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                                      forState: .Highlighted)
        sellButton.setBackgroundImage(UIColor.primaryColorDisabled.imageWithSize(CGSize(width: 1, height: 1)),
                                      forState: .Disabled)
        sellButton.addTarget(self, action: #selector(runSellCompletion), forControlEvents: .TouchUpInside)

        giveAwayButton.setTitle(LGLocalizedString.tabBarGiveAwayButton, forState: .Normal)
        giveAwayButton.setTitleColor(UIColor.primaryColor, forState: .Normal)
        let giveAwayButtonImage = UIImage(named: "ic_main_give_away")
        giveAwayButton.setImage(giveAwayButtonImage, forState: .Normal)
        giveAwayButton.setImage(giveAwayButtonImage, forState: .Highlighted)
        giveAwayButton.setBackgroundImage(UIColor.secondaryColor.imageWithSize(CGSize(width: 1, height: 1)),
                                          forState: .Normal)
        giveAwayButton.setBackgroundImage(UIColor.secondaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                                          forState: .Highlighted)
        giveAwayButton.setBackgroundImage(UIColor.secondaryColorDisabled.imageWithSize(CGSize(width: 1, height: 1)),
                                          forState: .Disabled)
        giveAwayButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: titleIconSpacing, bottom: 0, right: -titleIconSpacing)
        giveAwayButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: extraPadding, bottom: 0, right: 2*titleIconSpacing+extraPadding)
        giveAwayButton.addTarget(self, action: #selector(runGiveAwayCompletion), forControlEvents: .TouchUpInside)
    }

    private dynamic func runSellCompletion() {
        sellCompletion?()
    }

    private dynamic func runGiveAwayCompletion() {
        giveAwayCompletion?()
    }
}
