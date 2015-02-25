//
//  UIViewController+Ambatana.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 09/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaFadingAlertDismissalTime: Double = 3.0
private let kAmbatanaSearchBarHeight: CGFloat = 44

extension UIViewController {
    
    // Sets the Ambatana navigation bar style. Should be called by every VC embedded in a UINavigationController.
    func setAmbatanaNavigationBarStyle(title: AnyObject? = nil, includeBackArrow: Bool = true) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        
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
    
    // Used to set right buttons in the Ambatana style and link them with proper actions.
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
    
    // gets back one VC from the stack.
    func popBackViewController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Shows an alert message that fades out after kAmbatanaFadingAlertDismissalTime seconds
    func showAutoFadingOutMessageAlert(message: String, completionBlock: ((Void) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        if completionBlock == nil { NSTimer.scheduledTimerWithTimeInterval(kAmbatanaFadingAlertDismissalTime, target: self, selector: "dismissAlert", userInfo: nil, repeats: false) }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kAmbatanaFadingAlertDismissalTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    completionBlock!()
                })
            }
        }
    }
    
    // Shows a loading alert message. It will not fade away, so must be explicitly dismissed by calling dismissAlert() or invoking dismissViewControllerAnimated:completion: directly.
    func showLoadingMessageAlert(customMessage: String? = translate("loading")) {
        let finalMessage = (customMessage ?? translate("loading"))+"\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .Alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // dismisses a previously shown loading alert message.
    func dismissAlert() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Creates and shows a searching bar, that will be placed just below the UINavigationController, and allow the user to look for products.
    func showSearchBarAnimated(animated: Bool, delegate: UISearchBarDelegate) {
        // generate the search bar.
        let originY = statusBarHeight() + (self.navigationController?.navigationBar.frame.size.height ?? 0)
        let searchBar = UISearchBar(frame: CGRectMake(0, animated ? -kAmbatanaSearchBarHeight : originY, kAmbatanaFullScreenWidth, kAmbatanaSearchBarHeight))
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.delegate = delegate
        searchBar.becomeFirstResponder()
        
        // add it to current view
        self.view.addSubview(searchBar)
        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                searchBar.frame.origin.y = originY
            })
        }
    }
    
    func dismissSearchBar(searchBar: UISearchBar, animated: Bool, searchBarCompletion: ((Void) -> Void)?) {
        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                searchBar.frame.origin.y = -kAmbatanaSearchBarHeight
            }, completion: { (success) -> Void in
                searchBar.resignFirstResponder()
                self.view.endEditing(true)
                searchBar.removeFromSuperview()
                searchBarCompletion?()
            })
        } else {
            searchBar.resignFirstResponder()
            self.view.endEditing(true)
            searchBar.removeFromSuperview()
            searchBarCompletion?()
        }
    }
    
}














