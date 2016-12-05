//
//  UIViewController+LG.swift
//  LetGo
//
//

import UIKit
import SafariServices
import RxSwift

// MARK: - UINavigationBar helpers

extension UIViewController {

    var barButtonsHoritzontalSpacing: CGFloat {
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            return 8
        default:
            return 16
        }
    }

    func isRootViewController() -> Bool  {
        guard navigationController?.viewControllers.count > 0 else { return false }
        return navigationController?.viewControllers[0] == self
    }

    func setLetGoRightButtonWith(action: UIAction, disposeBag: DisposeBag, buttonTintColor: UIColor? = nil) -> UIBarButtonItem? {
        let rightItem = UIBarButtonItem()
        rightItem.tintColor = buttonTintColor
        rightItem.style = .Plain
        if let image = action.image {
            if let _ = buttonTintColor {
                rightItem.image = image.imageWithRenderingMode(.AlwaysTemplate)
            } else {
                rightItem.image = image
            }
        } else if let text = action.text {
            rightItem.title = text
        } else {
            return nil
        }
        rightItem.rx_tap.bindNext{
            action.action()
        }.addDisposableTo(disposeBag)
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightItem
        return rightItem
    }

    func setLetGoRightButtonWith(text text: String, selector: String) -> UIBarButtonItem {
        let rightItem = UIBarButtonItem(title: text, style: .Plain, target: self, action: Selector(selector))
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightItem
        return rightItem
    }

    func setLetGoRightButtonWith(imageName image: String, selector: String,
        buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
            return setLetGoRightButtonWith(imageName: image, renderingMode: .AlwaysTemplate, selector: selector,
                buttonsTintColor: buttonsTintColor)
    }
    
    func setLetGoRightButtonWith(imageName image: String, renderingMode: UIImageRenderingMode,
        selector: String, buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
        return setLetGoRightButtonWith(image: UIImage(named: image), renderingMode: renderingMode, selector: selector,
                                       buttonsTintColor: buttonsTintColor)
    }

    func setLetGoRightButtonWith(image image: UIImage?, renderingMode: UIImageRenderingMode,
                                           selector: String, buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
        let itemImage = image?.imageWithRenderingMode(renderingMode)
        let rightitem = UIBarButtonItem(image:itemImage,
                                        style: UIBarButtonItemStyle.Plain, target: self, action: Selector(selector))
        rightitem.tintColor = buttonsTintColor
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightitem
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

        var x: CGFloat = 0
        
        let items: [UIBarButtonItem] = buttons.flatMap { button in
            guard let icon = button.imageForState(.Normal) else { return nil }
            
            let buttonWidth = icon.size.width + barButtonsHoritzontalSpacing
            button.frame = CGRect(x: x, y: 0, width: buttonWidth, height: height)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
            
            x += buttonWidth
            
            return UIBarButtonItem(customView: button)
        }

        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = items.reverse()
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

    /**
     Helper to recursively dismiss all presented view controllers
     */
    func dismissAllPresented(completion: (() -> ())?) {
        guard let presented = presentedViewController else {
            completion?()
            return
        }
        presented.dismissAllPresented(nil)
        presented.dismissViewControllerAnimated(false, completion: completion)
    }
}


// MARK: - Internal urls presenters

extension UIViewController {
    func openInternalUrl(url: NSURL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.primaryColor
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


// MARK: - TabBar

extension UIViewController {
    func containsTabBar() -> Bool {
        guard let tabBarShowable = self as? TabBarShowable else { return false }
        return tabBarShowable.hasTabBar
    }
}
