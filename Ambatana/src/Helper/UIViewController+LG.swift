//
//  UIViewController+LG.swift
//  LetGo
//
//

import UIKit
import SafariServices

// MARK: - UINavigationBar helpers

extension UIViewController {

    func isRootViewController() -> Bool  {
        guard navigationController?.viewControllers.count > 0 else { return false }
        return navigationController?.viewControllers[0] == self
    }
    
    // Sets the LetGo navigation bar style. Should be called by every VC embedded in a UINavigationController.
    func setLetGoNavigationBarStyle(title: AnyObject? = nil, backIcon: UIImage? = nil) {
        // title
        if let titleString = title as? String {
            self.navigationItem.title = titleString
        } else if let titleImage = title as? UIImage {
            self.navigationItem.titleView = UIImageView(image: titleImage)
        } else if let titleView = title as? UIView {
            self.navigationItem.titleView = titleView
        }

        // back button
        if !isRootViewController() {
            let backIconImage = backIcon ?? UIImage(named: "navbar_back")
            let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.Plain,
                target: self, action: #selector(UIViewController.popBackViewController))
            self.navigationItem.leftBarButtonItem = backButton
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        }
    }

    func setLetGoRightButtonWith(imageName image: String, selector: String,
        buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
            return setLetGoRightButtonWith(imageName: image, renderingMode: .AlwaysTemplate, selector: selector,
                buttonsTintColor: buttonsTintColor)
    }
    
    func setLetGoRightButtonWith(imageName image: String, renderingMode: UIImageRenderingMode,
        selector: String, buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
            let itemImage = UIImage(named: image)?.imageWithRenderingMode(renderingMode)
            let rightitem = UIBarButtonItem(image:itemImage,
                style: UIBarButtonItemStyle.Plain, target: self, action: Selector(selector))
            rightitem.tintColor = buttonsTintColor
            self.navigationItem.rightBarButtonItem = rightitem
            return rightitem
    }
    
    // Used to set right buttons in the LetGo style and link them with proper actions.
    func setLetGoRightButtonsWith(imageNames images: [String], selectors: [String], tags: [Int]? = nil) -> [UIButton] {
        let renderingMode: [UIImageRenderingMode] = images.map({ _ in return .AlwaysTemplate })
        return setLetGoRightButtonsWith(imageNames: images, renderingMode: renderingMode, selectors: selectors,
            tags: tags)
    }

    func setLetGoRightButtonsWith(imageNames images: [String], renderingMode: [UIImageRenderingMode],
        selectors: [String], tags: [Int]? = nil) -> [UIButton] {
            if (images.count != selectors.count) { return [] }

            var buttons: [UIButton] = []
            for i in 0..<images.count {
                let button = UIButton(type: .System)
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
                button.tag = tags != nil ? tags![i] : i
                button.setImage(UIImage(named: images[i])?.imageWithRenderingMode(renderingMode[i]), forState: .Normal)
                button.addTarget(self, action: Selector(selectors[i]), forControlEvents: UIControlEvents.TouchUpInside)
                buttons.append(button)
            }

            setNavigationBarRightButtons(buttons)

            return buttons
    }

    func setNavigationBarRightButtons(buttons: [UIButton]) {
        let height: CGFloat = 44
        let hSpacing: CGFloat = 24

        var x: CGFloat = 0
        var width: CGFloat = 0

        buttons.forEach { button in
            guard let icon = button.imageForState(.Normal) else { return }

            let buttonWidth = icon.size.width + hSpacing
            button.frame = CGRect(x: x, y: 0, width: buttonWidth, height: height)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right

            x += buttonWidth
            width += buttonWidth
        }

        let buttonsFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let buttonsView = UIView(frame: buttonsFrame)

        buttons.forEach { button in
            buttonsView.addSubview(button)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonsView)
    }
}


// MARK: - Present/pop

extension UIViewController {

    // gets back one VC from the stack.
    func popBackViewController() {
        self.navigationController?.popViewControllerAnimated(true)
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

    /**
    Helper to provide a callback to the popViewController action

    - parameter animated:   whether to animate or not
    - parameter completion: completion callback
    */
    func popViewController(animated animated: Bool, completion: (() -> Void)?) {
        guard let navigationController = navigationController else { return }
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            navigationController.popViewControllerAnimated(true)
            CATransaction.commit()
        } else {
            navigationController.popViewControllerAnimated(false)
            completion?()
        }
    }

    /**
    Helper to provide a callback to the pushViewController action

    - parameter animated:   whether to animate or not
    - parameter completion: completion callback
    */
    func pushViewController(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let navigationController = navigationController else { return }
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            navigationController.pushViewController(viewController, animated: true)
            CATransaction.commit()
        } else {
            navigationController.pushViewController(viewController, animated: false)
            completion?()
        }
    }
}


// MARK: - Alerts and loading helpers

private struct AlertKeys {
    static var LoadingKey = 0
}

private let kLetGoFadingAlertDismissalTime: Double = 2.5

extension UIViewController {

    private var loading: UIAlertController? {
        get {
            return (objc_getAssociatedObject(self, &AlertKeys.LoadingKey) as? UIAlertController)
        }

        set {
            objc_setAssociatedObject(
                self,
                &AlertKeys.LoadingKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
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
        guard self.loading == nil else { return }

        let finalMessage = (customMessage ?? LGLocalizedString.commonLoading)+"\n\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .Alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        self.loading = alert
        presentViewController(alert, animated: true, completion: nil)
    }

    // dismisses a previously shown loading alert message (iOS 8 -- UIAlertController style, iOS 7 -- UIAlertView style)
    func dismissLoadingMessageAlert(completion: (() -> Void)? = nil) {
        if let alert = self.loading {
            self.loading = nil
            alert.dismissViewControllerAnimated(true, completion: completion)
        } else {
            completion?()
        }
    }
}


// MARK: - Internal urls presenters

extension UIViewController {
    func openInternalUrl(url: NSURL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
            svc.view.tintColor = StyleHelper.primaryColor
            self.presentViewController(svc, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}


// MARK: - Status bar

enum StatusBarNotification: String {
    case StatusBarWillHide
    case StatusBarWillShow
    case StatusBarDidHide
    case StatusBarDidShow
}

extension UIViewController {

    func setStatusBarHidden(hidden: Bool) {
        setStatusBarHidden(hidden, withAnimation: nil)
    }

    func setStatusBarHidden(hidden: Bool, withAnimation animation: UIStatusBarAnimation?) {

        let willNotificationName: StatusBarNotification = hidden ? .StatusBarWillHide : .StatusBarWillShow
        let didNotificationName: StatusBarNotification = hidden ? .StatusBarDidHide : .StatusBarDidShow
        NSNotificationCenter.defaultCenter().postNotificationName(willNotificationName.rawValue, object: nil)

        if let animation = animation {
            UIApplication.sharedApplication().setStatusBarHidden(hidden, withAnimation: animation)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(didNotificationName.rawValue, object: nil)
            }
        } else {
            UIApplication.sharedApplication().statusBarHidden = hidden
            NSNotificationCenter.defaultCenter().postNotificationName(didNotificationName.rawValue, object: nil)
        }
    }
}
