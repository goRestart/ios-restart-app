//
//  UIViewController+LetGo.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 09/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
import UIKit

protocol NativeShareDelegate {
    func nativeShareInFacebook()
    func nativeShareInTwitter()
    func nativeShareInEmail()
    func nativeShareInWhatsApp()
}

private let kLetGoFadingAlertDismissalTime: Double = 2.5
private let kLetGoBadgeContainerViewTag = 500

extension UIViewController {
    
    // Sets the LetGo navigation bar style. Should be called by every VC embedded in a UINavigationController.
    func setLetGoNavigationBarStyle(title: AnyObject? = nil) {
        // title
        if let titleString = title as? String {
            self.navigationItem.title = titleString
        } else if let titleImage = title as? UIImage {
            self.navigationItem.titleView = UIImageView(image: titleImage)
        } else if let titleView = title as? UIView {
            self.navigationItem.titleView = titleView
        }

        // back button
        let includeBackArrow = self.navigationController?.viewControllers.count > 1
        if includeBackArrow {
            let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popBackViewController")
            self.navigationItem.leftBarButtonItem = backButton
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        }
    }

    func setLetGoRightButtonWith(imageName image: String, selector: String) -> UIBarButtonItem {
        return setLetGoRightButtonWith(imageName: image, renderingMode: .AlwaysTemplate, selector: selector)
    }
    
    func setLetGoRightButtonWith(imageName image: String, renderingMode: UIImageRenderingMode,
        selector: String) -> UIBarButtonItem {
            let itemImage = UIImage(named: image)?.imageWithRenderingMode(renderingMode)
            let rightitem = UIBarButtonItem(image:itemImage,
                style: UIBarButtonItemStyle.Plain, target: self, action: Selector(selector))
            self.navigationItem.rightBarButtonItem = rightitem
            return rightitem
    }
    
    // Used to set right buttons in the LetGo style and link them with proper actions.
    func setLetGoRightButtonsWith(imageNames images: [String], selectors: [String],
        tags: [Int]? = nil) -> [UIButton] {
            return setLetGoRightButtonsWith(imageNames: images, renderingMode: .AlwaysTemplate, selectors: selectors,
                tags: tags)
    }

    func setLetGoRightButtonsWith(imageNames images: [String], renderingMode: UIImageRenderingMode, selectors: [String],
        tags: [Int]? = nil) -> [UIButton] {

            if (images.count != selectors.count) { return [] } // we need as many images as selectors and viceversa

            var resultButtons: [UIButton] = []
            let hSpacing: CGFloat = 24

            var x: CGFloat = 0
            let height: CGFloat = 44
            var width: CGFloat = 0
            
            for i in 0..<images.count {
                let image = UIImage(named: images[i])!
                let buttonWidth = image.size.width + hSpacing            // image width + horizontal spacing

                let button = UIButton(type: .System)
                button.frame = CGRectMake(x, 0, buttonWidth, height)
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
                button.tag = tags != nil ? tags![i] : i
                button.setImage(UIImage(named: images[i])?.imageWithRenderingMode(renderingMode), forState: .Normal)
                button.addTarget(self, action: Selector(selectors[i]), forControlEvents: UIControlEvents.TouchUpInside)
                resultButtons.append(button)
                
                x += image.size.width + hSpacing
                width += buttonWidth
            }

            let buttonsFrame = CGRect(x: 0, y: 0, width: width, height: height)
            let buttonsView = UIView(frame: buttonsFrame)
            
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
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        presentViewController(alert, animated: true, completion: nil)
        // Schedule auto fading out of alert message
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            alert.dismissViewControllerAnimated(true, completion: { () -> Void in
                if completionBlock != nil { completionBlock!() }
            })
        }
    }
    
    // Shows a loading alert message. It will not fade away, so must be explicitly dismissed by calling dismissAlert()
    func showLoadingMessageAlert(customMessage: String? = LGLocalizedString.commonLoading) {
        let finalMessage = (customMessage ?? LGLocalizedString.commonLoading)+"\n\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .Alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // dismisses a previously shown loading alert message (iOS 8 -- UIAlertController style, iOS 7 -- UIAlertView style)
    func dismissLoadingMessageAlert(completion: ((Void) -> Void)? = nil) {
        dismissViewControllerAnimated(true, completion: completion)
    }

    
    // Shows a custom loading alert message. It will not fade away, so must be explicitly dismissed by calling 
    // dismissAlert().  Used to patch FB login in iOS 9
    func showCustomLoadingMessageAlert(customMessage: String? = LGLocalizedString.commonLoading) {
        let bgVC = UIViewController()
        bgVC.modalPresentationStyle =  UIModalPresentationStyle.OverCurrentContext
        bgVC.view.backgroundColor =  UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        bgVC.view.frame = self.view.frame
        bgVC.view.center = self.view.center
        
        let alert = UIView(frame: CGRectMake(0, 0, 260, 120))
        alert.center = bgVC.view.center
        alert.backgroundColor = UIColor.whiteColor()
        alert.layer.cornerRadius = 10
        
        let messageLabel = UILabel(frame:CGRectMake(10, 0, 240, 50))
        messageLabel.font = UIFont.boldSystemFontOfSize(17)
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.numberOfLines = 0
        messageLabel.text = customMessage
        alert.addSubview(messageLabel)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 85.5)
        alert.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        bgVC.view.addSubview(alert)
        alert.alpha = 0
        
        presentViewController(bgVC, animated: false) { () -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                alert.alpha = 1
            })
        }
    }

    func presentNativeShareWith(shareText shareText: String, delegate: NativeShareDelegate?) {

        let activityItems: [AnyObject] = [shareText]
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        // src: http://stackoverflow.com/questions/25759380/launchservices-invalidationhandler-called-ios-8-share-sheet
        if vc.respondsToSelector("popoverPresentationController") {
            let presentationController = vc.popoverPresentationController
            presentationController?.sourceView = self.view
        }

        vc.completionWithItemsHandler = {
            [weak self] (activity, success, items, error) in

            // TODO: comment left here as a clue to manage future activities
            /*   SAMPLES OF SHARING RESULTS VIA ACTIVITY VC

            println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")

            Activity: com.apple.UIKit.activity.PostToFacebook Success: true Items: nil Error: nil
            Activity: net.whatsapp.WhatsApp.ShareExtension Success: true Items: nil Error: nil
            Activity: com.apple.UIKit.activity.Mail Success: true Items: nil Error: nil
            Activity: com.apple.UIKit.activity.PostToTwitter Success: true Items: nil Error: nil
            */

            guard success else {
                //In case of cancellation just do nothing -> success == false && error == nil
                guard error != nil else { return }

                self?.showAutoFadingOutMessageAlert(LGLocalizedString.productShareGenericError)
                return
            }

            if activity == UIActivityTypePostToFacebook {
                delegate?.nativeShareInFacebook()
            } else if activity == UIActivityTypePostToTwitter {
                delegate?.nativeShareInTwitter()
            } else if activity == UIActivityTypeMail {
                delegate?.nativeShareInEmail()
            } else if activity != nil && activity!.rangeOfString("whatsapp") != nil {
                delegate?.nativeShareInWhatsApp()
            }

            self?.showAutoFadingOutMessageAlert(LGLocalizedString.productShareGenericOk)
        }
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    // dismisses a previously shown custom loading alert message.  Used to patch FB login in iOS 9
    func dismissCustomLoadingMessageAlert(completion: ((Void) -> Void)? = nil) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.presentedViewController?.view.alpha = 0
            }) { (finished) -> Void in
                self.dismissViewControllerAnimated(true, completion: completion)
        }
    }

    /**
        Helper to present a view controller using the main thread 
    */
    func presentViewController(viewControllerToPresent: UIViewController, animated: Bool, onMainThread: Bool,
        completion: (() -> Void)?) {
            if onMainThread {
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    self?.presentViewController(viewControllerToPresent, animated: animated, completion: completion)
                }
            }
            else {
                self.presentViewController(viewControllerToPresent, animated: animated, completion: completion)
            }
    }
    
}