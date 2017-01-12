//
//  UIViewController+LG.swift
//  LetGo
//
//

import UIKit
import SafariServices
import RxSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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

    @discardableResult 
    func setLetGoRightButtonWith(_ action: UIAction, disposeBag: DisposeBag, buttonTintColor: UIColor? = nil) -> UIBarButtonItem? {
        let rightItem = UIBarButtonItem()
        rightItem.tintColor = buttonTintColor
        rightItem.style = .plain
        if let image = action.image {
            if let _ = buttonTintColor {
                rightItem.image = image.withRenderingMode(.alwaysTemplate)
            } else {
                rightItem.image = image
            }
        } else if let text = action.text {
            rightItem.title = text
        } else {
            return nil
        }
        rightItem.rx.tap.bindNext{
            action.action()
        }.addDisposableTo(disposeBag)
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightItem
        return rightItem
    }

    func setLetGoRightButtonWith(text: String, selector: String) -> UIBarButtonItem {
        let rightItem = UIBarButtonItem(title: text, style: .plain, target: self, action: Selector(selector))
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightItem
        return rightItem
    }

    @discardableResult
    func setLetGoRightButtonWith(imageName image: String, selector: String,
        buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
            return setLetGoRightButtonWith(imageName: image, renderingMode: .alwaysTemplate, selector: selector,
                buttonsTintColor: buttonsTintColor)
    }

    @discardableResult
    func setLetGoRightButtonWith(imageName image: String, renderingMode: UIImageRenderingMode,
        selector: String, buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
        return setLetGoRightButtonWith(image: UIImage(named: image), renderingMode: renderingMode, selector: selector,
                                       buttonsTintColor: buttonsTintColor)
    }

    func setLetGoRightButtonWith(image: UIImage?, renderingMode: UIImageRenderingMode,
                                           selector: String, buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
        let itemImage = image?.withRenderingMode(renderingMode)
        let rightitem = UIBarButtonItem(image:itemImage,
                                        style: UIBarButtonItemStyle.plain, target: self, action: Selector(selector))
        rightitem.tintColor = buttonsTintColor
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightitem
        return rightitem
    }
    
    // Used to set right buttons in the LetGo style and link them with proper actions.
    func setLetGoRightButtonsWith(imageNames images: [String], selectors: [String], tags: [Int]? = nil) -> [UIButton] {
        let renderingMode: [UIImageRenderingMode] = images.map({ _ in return .alwaysTemplate })
        return setLetGoRightButtonsWith(imageNames: images, renderingMode: renderingMode, selectors: selectors,
            tags: tags)
    }

    func setLetGoRightButtonsWith(imageNames images: [String], renderingMode: [UIImageRenderingMode],
        selectors: [String], tags: [Int]? = nil) -> [UIButton] {
            if (images.count != selectors.count) { return [] }

            var buttons: [UIButton] = []
            for i in 0..<images.count {
                let button = UIButton(type: .system)
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
                button.tag = tags != nil ? tags![i] : i
                button.setImage(UIImage(named: images[i])?.withRenderingMode(renderingMode[i]), for: UIControlState())
                button.addTarget(self, action: Selector(selectors[i]), for: UIControlEvents.touchUpInside)
                buttons.append(button)
            }

            setNavigationBarRightButtons(buttons)

        return buttons
    }
    
    func setNavigationBarRightButtons(_ buttons: [UIButton]) {
        let height: CGFloat = 44

        var x: CGFloat = 0
        
        let items: [UIBarButtonItem] = buttons.flatMap { button in
            guard let icon = button.image(for: UIControlState()) else { return nil }
            
            let buttonWidth = icon.size.width + barButtonsHoritzontalSpacing
            button.frame = CGRect(x: x, y: 0, width: buttonWidth, height: height)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
            
            x += buttonWidth
            
            return UIBarButtonItem(customView: button)
        }

        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = items.reversed()
    }
}


// MARK: - Present/pop

extension UIViewController {

    // gets back one VC from the stack.
    func popBackViewController() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    /**
    Helper to present a view controller using the main thread
    */
    func presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool, onMainThread: Bool,
        completion: (() -> Void)?) {
            if onMainThread {
                DispatchQueue.main.async { [weak self] in
                    self?.present(viewControllerToPresent, animated: animated, completion: completion)
                }
            }
            else {
                self.present(viewControllerToPresent, animated: animated, completion: completion)
            }
    }

    /**
    Helper to provide a callback to the popViewController action

    - parameter animated:   whether to animate or not
    - parameter completion: completion callback
    */
    func popViewController(animated: Bool, completion: (() -> Void)?) {
        guard let navigationController = navigationController else { return }
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            navigationController.popViewController(animated: true)
            CATransaction.commit()
        } else {
            navigationController.popViewController(animated: false)
            completion?()
        }
    }

    /**
    Helper to provide a callback to the pushViewController action

    - parameter animated:   whether to animate or not
    - parameter completion: completion callback
    */
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
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
    func dismissAllPresented(_ completion: (() -> ())?) {
        guard let presented = presentedViewController else {
            completion?()
            return
        }
        presented.dismissAllPresented(nil)
        presented.dismiss(animated: false, completion: completion)
    }
}


// MARK: - Internal urls presenters

extension UIViewController {
    func openInternalUrl(_ url: URL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.primaryColor
            self.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
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

    func setStatusBarHidden(_ hidden: Bool) {
        setStatusBarHidden(hidden, withAnimation: nil)
    }

    func setStatusBarHidden(_ hidden: Bool, withAnimation animation: UIStatusBarAnimation?) {

        let willNotificationName: StatusBarNotification = hidden ? .StatusBarWillHide : .StatusBarWillShow
        let didNotificationName: StatusBarNotification = hidden ? .StatusBarDidHide : .StatusBarDidShow
        NotificationCenter.default.post(name: Notification.Name(rawValue: willNotificationName.rawValue), object: nil)

        if let animation = animation {
            UIApplication.shared.setStatusBarHidden(hidden, with: animation)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: didNotificationName.rawValue), object: nil)
            }
        } else {
            UIApplication.shared.isStatusBarHidden = hidden
            NotificationCenter.default.post(name: Notification.Name(rawValue: didNotificationName.rawValue), object: nil)
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
