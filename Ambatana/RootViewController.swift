//
//  RootViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class RootViewController: DLHamburguerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // register as observer for kLetGoSessionInvalidatedNotification for session invalidation.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionInvalidated:", name: kLetGoSessionInvalidatedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // de-register for kLetGoSessionInvalidatedNotification
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("navigationViewController") as UIViewController
        self.menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("menuViewController") as UIViewController
    }
    
    // MARK: - Notifications
    func sessionInvalidated(notification: NSNotification) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
