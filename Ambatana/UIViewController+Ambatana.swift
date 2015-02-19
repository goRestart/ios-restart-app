//
//  UIViewController+Ambatana.swift
//  Ambatana
//
//  Created by Nacho on 09/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

extension UIViewController {
    func setAmbatanaNavigationBarStyle(title: AnyObject? = nil, includeBackArrow: Bool = true) {
        // title
        if let titleString = title as? String {
            self.navigationItem.title = titleString
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor()];
        } else if let titleImage = title as? UIImage {
            self.navigationItem.titleView = UIImageView(image: titleImage)
        }

        // back button
        if includeBackArrow {
            let backButton = UIButton(frame: CGRectMake(0, 0, 32, 32))
            backButton.setImage(UIImage(named: "actionbar_chevron"), forState: .Normal)
            backButton.addTarget(self, action: "popBackViewController", forControlEvents: .TouchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            self.navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
            self.navigationItem.hidesBackButton = false
        } else {
            self.navigationItem.hidesBackButton = true
        }
    }
    
    func setAmbatanaRightButtonsWithImageNames(images: [String], andSelectors selectors: [String]) {
        if (images.count != selectors.count) { return } // we need as many images as selectors and viceversa
        
        let numberOfButtons = images.count
        let totalSize: CGFloat = CGFloat(numberOfButtons) * 35.0
        let buttonsView = UIView(frame: CGRectMake(0, 0, totalSize, 32))
        var offset: CGFloat = 0.0
        
        for (var i = 0; i < numberOfButtons; i++) {
            // create and set button.
            let button = UIButton(frame: CGRectMake(offset, 0, 32, 32))
            button.setImage(UIImage(named: images[i]), forState: .Normal)
            button.addTarget(self, action: Selector(selectors[i]), forControlEvents: UIControlEvents.TouchUpInside)
            buttonsView.addSubview(button)
            
            // update offset
            offset += 35
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonsView)
    }
    
    func popBackViewController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showAutoFadingOutMessageAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        NSTimer.scheduledTimerWithTimeInterval(Double(3.0), target: self, selector: "dismissAlert", userInfo: nil, repeats: false)
    }
    
    func showLoadingMessageAlert(customMessage: String?) {
        let alert = UIAlertController(title: customMessage ?? translate("loading"), message: nil, preferredStyle: .Alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 65.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissAlert() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}