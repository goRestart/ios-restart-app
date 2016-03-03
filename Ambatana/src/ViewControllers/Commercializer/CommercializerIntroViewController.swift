//
//  CommercializerIntroViewController.swift
//  LetGo
//
//  Created by Dídac on 03/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class CommercializerIntroViewController: UIViewController {

    @IBOutlet weak var topPopupView: UIView!
    @IBOutlet weak var promoteTitleLabel: UILabel!
    @IBOutlet weak var tryFeatureLabel: UILabel!
    @IBOutlet weak var chooseThemeLabel: UILabel!
    @IBOutlet weak var tapToPromoteLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // TODO: Localize labels!

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
