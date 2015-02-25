//
//  AmbatanaNavigationController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class AmbatanaNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureRecognized:"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func panGestureRecognized(sender: UIPanGestureRecognizer!) {
        // dismiss keyboard
        self.view.endEditing(true)
        self.frostedViewController.view.endEditing(true)
        
        // pass gesture to frosted view controller.
        self.frostedViewController.panGestureRecognized(sender)
    }
    
}
