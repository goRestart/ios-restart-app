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
    
    var topPopupViewHeight: CGFloat = 0.0

    weak var delegate: CommercializerIntroViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        view.opaque = false

        topPopupViewHeight = topPopupView.frame.size.height
        topPopupTopConstraint.constant = -topPopupViewHeight

        // TODO: Localize labels!

//        promoteTitleLabel.text = ""
//        tryFeatureLabel.text = ""
//        chooseThemeLabel.text = ""
//        tapToPromoteLabel.text = ""

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.topPopupTopConstraint.constant = 0
        view.setNeedsUpdateConstraints()

        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            },
            completion: nil)
    }

    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            self.delegate?.commercializerIntroIsDismissed()
        }
    }
}
