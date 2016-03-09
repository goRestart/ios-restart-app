//
//  CommercializerIntroViewController.swift
//  LetGo
//
//  Created by Dídac on 03/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol CommercializerIntroViewControllerDelegate: class {
    func commercializerIntroIsDismissed()
}

class CommercializerIntroViewController: UIViewController {

    @IBOutlet weak var topPopupView: UIView!
    @IBOutlet weak var promoteTitleLabel: UILabel!
    @IBOutlet weak var tryFeatureLabel: UILabel!
    @IBOutlet weak var chooseThemeLabel: UILabel!
    @IBOutlet weak var tapToPromoteLabel: UILabel!

    @IBOutlet weak var topPopupTopConstraint: NSLayoutConstraint!

    weak var delegate: CommercializerIntroViewControllerDelegate?


    // MARK: - Lifecycle

    init() {
        super.init(nibName: "CommercializerIntroViewController", bundle: nil)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        view.opaque = false

        promoteTitleLabel.text = LGLocalizedString.commercializerIntroTitleLabel
        tryFeatureLabel.text = LGLocalizedString.commercializerIntroTryFeatureLabel
        chooseThemeLabel.text = LGLocalizedString.commercializerIntroChoseThemeLabel
        tapToPromoteLabel.text = LGLocalizedString.commercializerIntroTapToCreateLabel

        let topPopupViewHeight = topPopupView.frame.size.height
        topPopupTopConstraint.constant = -topPopupViewHeight
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.topPopupTopConstraint.constant = 0
        view.setNeedsUpdateConstraints()

        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            },
            completion: nil)
    }


    // MARK: - actions

    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.delegate?.commercializerIntroIsDismissed()
        }
    }
}
