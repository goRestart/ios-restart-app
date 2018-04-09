//
//  UIViewController+LG.swift
//  LetGo
//
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

// MARK: - UINavigationBar helpers

fileprivate extension UIBarButtonItem {
    static func makeSpacingButton(with width: CGFloat) -> UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        button.width = width
        return button
    }
}

extension UIViewController {

    var isModal: Bool {
        if presentingViewController != nil { return true }
        if navigationController?.presentingViewController?.presentedViewController == navigationController { return true }
        if tabBarController?.presentingViewController is UITabBarController { return true }
        return false
    }

    var barButtonsHoritzontalSpacing: CGFloat {
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            return 8
        default:
            return 16
        }
    }

    func makeSpacingButton(withFixedWidth width: CGFloat) -> UIBarButtonItem {
        return UIBarButtonItem.makeSpacingButton(with: width)
    }

    func isRootViewController() -> Bool  {
        guard let navigationController = navigationController else { return false }
        guard navigationController.viewControllers.count > 0 else { return false }
        return navigationController.viewControllers[0] == self
    }
    
    @discardableResult 
    func setLetGoRightButtonWith(_ action: UIAction, buttonTintColor: UIColor? = nil, tapBlock: (ControlEvent<Void>) -> Void ) -> UIBarButtonItem? {
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
        tapBlock(rightItem.rx.tap)
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightItem
        return rightItem
    }

    @discardableResult
    func setLetGoRightButtonWith(text: String, selector: Selector) -> UIBarButtonItem {
        let rightItem = UIBarButtonItem(title: text, style: .plain, target: self, action: selector)
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
                button.setImage(UIImage(named: images[i])?.withRenderingMode(renderingMode[i]), for: .normal)
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
            guard let icon = button.image(for: .normal) else { return nil }
            
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

@objc extension UIViewController {

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
    func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
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
     Helper to dismiss vc and all presented view controllers
     */
    func dismissWithPresented(animated: Bool, completion: (() -> Void)?) {
        guard presentingViewController != nil else {
            completion?()
            return
        }
        dismissAllPresented() { [weak self] in
            self?.dismiss(animated: animated, completion: completion)
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
        presented.dismissAllPresented() {
            presented.dismiss(animated: false, completion: completion)
        }
    }
}


// MARK: - Internal urls presenters

extension UIViewController {
    func openInternalUrl(_ url: URL) {
        let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.primaryColor
            self.present(svc, animated: true, completion: nil)
    }
}

// MARK: - TabBar

extension UIViewController {
    func containsTabBar() -> Bool {
        guard let tabBarShowable = self as? TabBarShowable else { return false }
        return tabBarShowable.hasTabBar
    }
}
