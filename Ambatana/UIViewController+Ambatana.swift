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
private let kAmbatanaBadgeContainerViewTag = 500
private let kAmbatanaBadgeViewTag = 501

var iOS7LoadingAlertView: UIAlertView?

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
    // if badgeButtonPosition is specified, a badge number bubble will be added to the button in that position
    func setAmbatanaRightButtonsWithImageNames(images: [String], andSelectors selectors: [String], badgeButtonPosition: Int = -1) {
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
            
            // custom badge?
            if badgeButtonPosition == i { // && PFInstallation.currentInstallation().badge > 0 {
                let badgeView = CustomBadge.customBadgeWithString("\(PFInstallation.currentInstallation().badge)", withStringColor: UIColor.whiteColor(), withInsetColor: UIColor.redColor(), withBadgeFrame: false, withBadgeFrameColor: UIColor.clearColor(), withScale: 1.0, withShining: false)
                badgeView.center = CGPointMake(button.frame.size.width - 3, 0)
                badgeView.tag = kAmbatanaBadgeViewTag
                button.tag = kAmbatanaBadgeContainerViewTag
                button.addSubview(badgeView)
            }
            
            // update offset
            offset += 35
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonsView)
    }
    
    // Finds for a button containing a badge in the current Right bar button item and updates the results.
    func refreshBadgeButton() {
        if let customView = self.navigationItem.rightBarButtonItem?.customView {
            for subview in customView.subviews {
                if let button = subview as? UIButton {
                    if button.tag == kAmbatanaBadgeContainerViewTag {
                        for buttonSubview in button.subviews {
                            if let badgeView = buttonSubview as? CustomBadge {
                                badgeView.badgeText = "\(PFInstallation.currentInstallation().badge)"
                                badgeView.setNeedsDisplay()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // gets back one VC from the stack.
    func popBackViewController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Shows an alert message that fades out after kAmbatanaFadingAlertDismissalTime seconds
    func showAutoFadingOutMessageAlert(message: String, completionBlock: ((Void) -> Void)? = nil) {
        if iOSVersionAtLeast("8.0") { // Use the new UIAlertController.
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            // Schedule auto fading out of alert message
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kAmbatanaFadingAlertDismissalTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    if completionBlock != nil { completionBlock!() }
                })
            }
        } else { // fallback to ios 7 UIAlertView
            let alert = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alert.show()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kAmbatanaFadingAlertDismissalTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                alert.dismissWithClickedButtonIndex(0, animated: false)
                if completionBlock != nil { completionBlock!() }
            }
        }
    }
    
    // Shows a loading alert message. It will not fade away, so must be explicitly dismissed by calling dismissAlert()
    func showLoadingMessageAlert(customMessage: String? = translate("loading")) {
        if iOSVersionAtLeast("8.0") {
            let finalMessage = (customMessage ?? translate("loading"))+"\n\n"
            let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .Alert)
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityIndicator.color = UIColor.blackColor()
            activityIndicator.center = CGPointMake(130.5, 85.5)
            alert.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else { // fallback for iOS 7 using UIAlertView.
            if iOS7LoadingAlertView != nil {
                iOS7LoadingAlertView?.dismissWithClickedButtonIndex(0, animated: true)
                iOS7LoadingAlertView = nil
            }
            iOS7LoadingAlertView = UIAlertView(title: (customMessage ?? translate("loading"))+"\n\n", message: nil, delegate: nil, cancelButtonTitle: nil)
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityIndicator.color = UIColor.blackColor()
            activityIndicator.center = CGPointMake(130.5, 85.5)
            iOS7LoadingAlertView!.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            iOS7LoadingAlertView!.show()
        }
    }
    
    // dismisses a previously shown loading alert message (iOS 8 -- UIAlertController style, iOS 7 -- UIAlertView style)
    func dismissLoadingMessageAlert(completion: ((Void) -> Void)? = nil) {
        if iOSVersionAtLeast("8.0") {
            self.dismissViewControllerAnimated(true, completion: completion)
        } else { // fallback to iOS 7 UIAlertView style
            iOS7LoadingAlertView?.dismissWithClickedButtonIndex(0, animated: false)
            iOS7LoadingAlertView = nil
            completion?()
        }
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














