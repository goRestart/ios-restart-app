//
//  FloatingButton.swift
//  LetGo
//
//  Created by Albert Hernández López on 17/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class FloatingButton: UIView {
    private let sellButton: UIButton
    private let giveAwayButton: UIButton

    var sellCompletion: (() -> ())?
    var giveAwayCompletion: (() -> ())?


    // MARK: - Lifecycle

    convenience init() {
        self.init(freePostingMode: FeatureFlags.freePostingMode)
    }

    init(freePostingMode: FreePostingMode) {
        self.sellButton = UIButton(type: .Custom)
        self.giveAwayButton = UIButton(type: .Custom)

        super.init(frame: CGRect.zero)

        setupUI(freePostingMode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = CGRectGetHeight(frame) / 2
    }


    // MARK: - Private methods

    private func setupUI(freePostingMode: FreePostingMode) {
        // Shadow
        applyFloatingButtonShadow()

        // Constraints
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sellButton)
        giveAwayButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(giveAwayButton)

        let views: [String: AnyObject] = ["sb": sellButton, "gab": giveAwayButton]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sb]-0-|", options: [],
            metrics: nil, views: views))

        let hConstraintsVF: String
        switch freePostingMode {
        case .Disabled, .OneButton:
            hConstraintsVF = "H:|-0-[sb]-0-|"
        case .SplitButton:
            hConstraintsVF = "H:|-0-[sb]-0-[gab]-0-|"
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[gab]-0-|", options: [],
                metrics: nil, views: views))
        }
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(hConstraintsVF, options: [],
                                                                          metrics: nil, views: views)
        addConstraints(hConstraints)

        // Setup
        sellButton.setTitle(LGLocalizedString.tabBarToolTip, forState: .Normal)
        sellButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        sellButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        sellButton.setImage(UIImage(named: "ic_sell_white"), forState: .Normal)
        sellButton.addTarget(self, action: #selector(runSellCompletion), forControlEvents: .TouchUpInside)

        switch freePostingMode {
        case .Disabled, .OneButton:
            sellButton.setImageRight()
        case .SplitButton:
            break
        }

        giveAwayButton.setTitle("polles", forState: .Normal)
        giveAwayButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        giveAwayButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        giveAwayButton.setImage(UIImage(named: "ic_sell_white"), forState: .Normal)
        giveAwayButton.addTarget(self, action: #selector(runGiveAwayCompletion), forControlEvents: .TouchUpInside)
    }

    private dynamic func runSellCompletion() {
        sellCompletion?()
    }

    private dynamic func runGiveAwayCompletion() {
        giveAwayCompletion?()
    }
}
