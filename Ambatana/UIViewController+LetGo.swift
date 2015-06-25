//
//  UIViewController+LetGo.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 09/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
import UIKit

private let kLetGoFadingAlertDismissalTime: Double = 1.5
private let kLetGoSearchBarHeight: CGFloat = 44
private let kLetGoBadgeContainerViewTag = 500

var iOS7LoadingAlertView: UIAlertView?
var letGoSearchBar: UISearchBar?

extension UIViewController {
    
    // Sets the LetGo navigation bar style. Should be called by every VC embedded in a UINavigationController.
    func setLetGoNavigationBarStyle(title: AnyObject? = nil) {
        // title
        if let titleString = title as? String {
            self.navigationItem.title = titleString
        } else if let titleImage = title as? UIImage {
            self.navigationItem.titleView = UIImageView(image: titleImage)
        }

        // back button
        let includeBackArrow = self.navigationController?.viewControllers.count > 1
        if includeBackArrow {
            let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popBackViewController")
            self.navigationItem.leftBarButtonItem = backButton
            self.navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        }
    }
    
    // Used to set right buttons in the LetGo style and link them with proper actions.
    func setLetGoRightButtonsWithImageNames(images: [String], andSelectors selectors: [String], withTags tags: [Int]? = nil) -> [UIButton] {
        if (images.count != selectors.count) { return [] } // we need as many images as selectors and viceversa

        var resultButtons: [UIButton] = []
        let hSpacing: CGFloat = 24

        var x: CGFloat = 0
        var height: CGFloat = 44
        var width: CGFloat = 0
        
        for i in 0..<images.count {
            let image = UIImage(named: images[i])!
            let buttonWidth = image.size.width + hSpacing            // image width + horizontal spacing

            var button = UIButton.buttonWithType(.System) as! UIButton
            button.frame = CGRectMake(x, 0, buttonWidth, height)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
//            button.backgroundColor = UIColor.purpleColor()
            button.tag = tags != nil ? tags![i] : i
            button.setImage(UIImage(named: images[i])?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            button.addTarget(self, action: Selector(selectors[i]), forControlEvents: UIControlEvents.TouchUpInside)
            resultButtons.append(button)
            
            x += image.size.width + hSpacing
            width += buttonWidth
        }

        let buttonsFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let buttonsView = UIView(frame: buttonsFrame)
//        buttonsView.backgroundColor = UIColor.greenColor()
        
        // Adjust the button frame and add them as subviews
        for button in resultButtons {
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, height)
            buttonsView.addSubview(button)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonsView)
        return resultButtons
    }
    
    // gets back one VC from the stack.
    func popBackViewController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showAutoFadingOutMessageAlert(message: String, completionBlock: ((Void) -> Void)? = nil) {
        showAutoFadingOutMessageAlert(message, time: kLetGoFadingAlertDismissalTime, completionBlock: completionBlock)
    }
    
    // Shows an alert message that fades out after kLetGoFadingAlertDismissalTime seconds
    func showAutoFadingOutMessageAlert(message: String, time: Double, completionBlock: ((Void) -> Void)? = nil) {
        if iOSVersionAtLeast("8.0") { // Use the new UIAlertController.
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            // Schedule auto fading out of alert message
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                alert.dismissViewControllerAnimated(true, completion: { () -> Void in
                    if completionBlock != nil { completionBlock!() }
                })
            }
        } else { // fallback to ios 7 UIAlertView
            let alert = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alert.show()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                alert.dismissWithClickedButtonIndex(0, animated: false)
                if completionBlock != nil { completionBlock!() }
            }
        }
    }
    
    // Shows a loading alert message. It will not fade away, so must be explicitly dismissed by calling dismissAlert()
    func showLoadingMessageAlert(customMessage: String? = NSLocalizedString("common_loading", comment: "")) {
        if iOSVersionAtLeast("8.0") {
            let finalMessage = (customMessage ?? NSLocalizedString("common_loading", comment: ""))+"\n\n\n"
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
            iOS7LoadingAlertView = UIAlertView(title: (customMessage ?? NSLocalizedString("common_loading", comment: "")), message: nil, delegate: nil, cancelButtonTitle: nil)
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














