//
//  UIViewController+LetGo.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 09/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
import UIKit

private let kLetGoFadingAlertDismissalTime: Double = 3.0
private let kLetGoSearchBarHeight: CGFloat = 44
private let kLetGoBadgeContainerViewTag = 500
private let kLetGoBadgeViewTag = 501
private let kLetGoBarButtonSide: CGFloat = 32.0
private let kLetGoBarButtonSideSpan: CGFloat = 0.0 //8.0
private let kLetGoBarButtonHorizontalSpace: CGFloat = 3.0

var iOS7LoadingAlertView: UIAlertView?
var letGoSearchBar: UISearchBar?

extension UIViewController {
    
    // Sets the LetGo navigation bar style. Should be called by every VC embedded in a UINavigationController.
    func setLetGoNavigationBarStyle(title: AnyObject? = nil, includeBackArrow: Bool = true) {
        //self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_bar_bg")!, forBarMetrics: .Default)
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "nav_bar_bg")!, forBarMetrics: .Default)
        
        // title
        if let titleString = title as? String {
            self.navigationItem.title = titleString
        } else if let titleImage = title as? UIImage {
            self.navigationItem.titleView = UIImageView(image: titleImage)
        }

        // back button
        if includeBackArrow {
            let backButton = UIButton(frame: CGRectMake(0, 0, kLetGoBarButtonSide, kLetGoBarButtonSide)) // Issue #63: Add some span in width for better access to button.
            backButton.setImage(UIImage(named: "actionbar_chevron"), forState: .Normal)
            backButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -16, 0, 0) // adjust chevron to the left.
            backButton.addTarget(self, action: "popBackViewController", forControlEvents: .TouchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            self.navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
            self.navigationItem.hidesBackButton = false
        } else {
            self.navigationItem.hidesBackButton = true
        }
    }
    
    // Used to set right buttons in the LetGo style and link them with proper actions.
    // if badgeButtonPosition is specified, a badge number bubble will be added to the button in that position
    func setLetGoRightButtonsWithImageNames(images: [String], andSelectors selectors: [String], withTags tags: [Int]? = nil, badgeButtonPosition: Int = -1) -> [UIButton] {
        if (images.count != selectors.count) { return [] } // we need as many images as selectors and viceversa
        var resultButtons: [UIButton] = []
        
        let numberOfButtons = images.count
        let totalSize: CGFloat = CGFloat(numberOfButtons) * (kLetGoBarButtonSide + kLetGoBarButtonSideSpan + kLetGoBarButtonHorizontalSpace)
        let buttonsView = UIView(frame: CGRectMake(0, 0, totalSize, 32))
        var offset: CGFloat = 0.0
        
        for (var i = 0; i < numberOfButtons; i++) {
            // create and set button.
            var button = UIButton.buttonWithType(.System) as! UIButton
            button.frame = CGRectMake(offset, 0, kLetGoBarButtonSide + kLetGoBarButtonSideSpan, 32)
            button.tag = tags != nil ? tags![i] : i
            button.setImage(UIImage(named: images[i])?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            button.addTarget(self, action: Selector(selectors[i]), forControlEvents: UIControlEvents.TouchUpInside)
            buttonsView.addSubview(button)
            resultButtons.append(button)
            
            // custom badge?
            if badgeButtonPosition == i {
                let badgeView = CustomBadge.customBadgeWithString("\(PFInstallation.currentInstallation().badge)", withStringColor: UIColor.whiteColor(), withInsetColor: UIColor.redColor(), withBadgeFrame: false, withBadgeFrameColor: UIColor.clearColor(), withScale: 1.0, withShining: false)
                badgeView.center = CGPointMake(button.frame.size.width - 3, 0)
                badgeView.tag = kLetGoBadgeViewTag
                button.tag = kLetGoBadgeContainerViewTag
                button.addSubview(badgeView)
                
                if PFInstallation.currentInstallation().badge > 0 {
                    badgeView.hidden = false
                    badgeView.badgeText = "\(PFInstallation.currentInstallation().badge)"
                }
                else {
                    badgeView.hidden = true
                }
            }
            
            // update offset
            offset += kLetGoBarButtonSide + kLetGoBarButtonSideSpan + kLetGoBarButtonHorizontalSpace
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonsView)
        return resultButtons
    }
    
    // Finds for a button containing a badge in the current Right bar button item and updates the results.
    func refreshBadgeButton() {
        if let customView = self.navigationItem.rightBarButtonItem?.customView {
            for subview in customView.subviews {
                if let button = subview as? UIButton {
                    if button.tag == kLetGoBadgeContainerViewTag {
                        for buttonSubview in button.subviews {
                            if let badgeView = buttonSubview as? CustomBadge {
                                let badgeCount = PFInstallation.currentInstallation().badge
                                if badgeCount > 0 {
                                    badgeView.hidden = false
                                    badgeView.badgeText = "\(PFInstallation.currentInstallation().badge)"
                                }
                                else {
                                    badgeView.hidden = true
                                }
                                
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
    
    // Shows an alert message that fades out after kLetGoFadingAlertDismissalTime seconds
    func showAutoFadingOutMessageAlert(message: String, completionBlock: ((Void) -> Void)? = nil) {
        if iOSVersionAtLeast("8.0") { // Use the new UIAlertController.
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            // Schedule auto fading out of alert message
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kLetGoFadingAlertDismissalTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    if completionBlock != nil { completionBlock!() }
                })
            }
        } else { // fallback to ios 7 UIAlertView
            let alert = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alert.show()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kLetGoFadingAlertDismissalTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                alert.dismissWithClickedButtonIndex(0, animated: false)
                if completionBlock != nil { completionBlock!() }
            }
        }
    }
    
    // Shows a loading alert message. It will not fade away, so must be explicitly dismissed by calling dismissAlert()
    func showLoadingMessageAlert(customMessage: String? = translate("loading")) {
        if iOSVersionAtLeast("8.0") {
            let finalMessage = (customMessage ?? translate("loading"))+"\n\n\n"
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
            iOS7LoadingAlertView = UIAlertView(title: (customMessage ?? translate("loading")), message: nil, delegate: nil, cancelButtonTitle: nil)
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
        // safety check
        if letGoSearchBar != nil { return }
        
        // generate the search bar.
        let originY = statusBarHeight() + (self.navigationController?.navigationBar.frame.size.height ?? 0)
        letGoSearchBar = UISearchBar(frame: CGRectMake(0, animated ? -kLetGoSearchBarHeight : originY, kLetGoFullScreenWidth, kLetGoSearchBarHeight))
        letGoSearchBar!.showsCancelButton = true
        letGoSearchBar!.backgroundColor = UIColor.whiteColor()
        letGoSearchBar!.delegate = delegate
        letGoSearchBar!.becomeFirstResponder()

        // add it to current view
        self.view.addSubview(letGoSearchBar!)
        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                letGoSearchBar!.frame.origin.y = originY
            })
        }
    }
    
    func dismissSearchBar(searchBar: UISearchBar, animated: Bool, searchBarCompletion: ((Void) -> Void)?) {
        if letGoSearchBar == nil { return }
        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                searchBar.frame.origin.y = -kLetGoSearchBarHeight
            }, completion: { (success) -> Void in
                searchBar.resignFirstResponder()
                self.view.endEditing(true)
                searchBar.removeFromSuperview()
                letGoSearchBar = nil
                searchBarCompletion?()
            })
        } else {
            searchBar.resignFirstResponder()
            self.view.endEditing(true)
            searchBar.removeFromSuperview()
            letGoSearchBar = nil
            searchBarCompletion?()
        }
    }
    
}














