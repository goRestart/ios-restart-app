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

struct ButtonImage {
    let normal: UIImage
    let selected: UIImage
    
    init(normal: UIImage, selected: UIImage) {
        self.normal = normal
        self.selected = selected
    }
    
    init(normal: UIImage) {
        self.normal = normal
        self.selected = normal
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
            return 4
        default:
            return 8
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
    func setLetGoRightButtonWith(barButtonSystemItem: UIBarButtonSystemItem,
                                 selector: Selector,
                                 animated: Bool = false) -> UIBarButtonItem {
        let rightItem = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: self, action: selector)
        navigationItem.setRightBarButtonItems(nil, animated: animated)
        navigationItem.setRightBarButton(rightItem, animated: animated)
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
    func setLetGoRightButtonWith(image: UIImage, selector: String,
        buttonsTintColor: UIColor? = nil) -> UIBarButtonItem {
            return setLetGoRightButtonWith(image: image, renderingMode: .alwaysTemplate, selector: selector,
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
    
    @discardableResult
    func setLetGoRightButtonsWith(images: [UIImage], selectors: [Selector], tags: [Int]? = nil) -> [UIButton] {
        let renderingMode: [UIImageRenderingMode] = images.map({ _ in return .alwaysOriginal })
        return setLetGoRightButtonsWith(images: images, renderingMode: renderingMode, selectors: selectors,
            tags: tags)
    }
    
    @discardableResult
    /// Set right navigation bar buttons
    ///
    /// - Parameters:
    ///   - buttonImages: a struct contains image for .normal and .selected button control state
    ///   - selectors: button selectors
    ///   - tags: button tag
    /// - Returns: a list of UIButtons for navigation bar right navigation items
    func setLetGoRightButtonsWith(buttonImages: [ButtonImage],
                                  selectors: [Selector],
                                  tags: [Int]? = nil) -> [UIButton] {
        let renderingMode: [UIImageRenderingMode] = buttonImages.map({ _ in return .alwaysOriginal })
        return setLetGoRightButtonsWith(buttonImages: buttonImages, renderingMode: renderingMode, selectors: selectors,
                                        tags: tags)
    }
    
    private func setLetGoRightButtonsWith(buttonImages: [ButtonImage], renderingMode: [UIImageRenderingMode],
                                          selectors: [Selector], tags: [Int]? = nil) -> [UIButton] {
        if (buttonImages.count != selectors.count) { return [] }
        
        var buttons: [UIButton] = []
        for i in 0..<buttonImages.count {
            let button = configureButton(image: buttonImages[i].normal,
                                         selectedImage: buttonImages[i].selected,
                                         renderingMode: renderingMode[i],
                                         selector: selectors[i],
                                         tag: tags != nil ? tags![i] : i)
            buttons.append(button)
        }
        
        setNavigationBarRightButtons(buttons)
        
        return buttons
    }
    
    private func setLetGoRightButtonsWith(images: [UIImage],
                                          renderingMode: [UIImageRenderingMode],
                                          selectors: [Selector],
                                          tags: [Int]? = nil) -> [UIButton] {
            if (images.count != selectors.count) { return [] }

            var buttons: [UIButton] = []
            for i in 0..<images.count {

                let button = UIButton(type: .system)
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
                button.tag = tags != nil ? tags![i] : i
                button.setImage(images[i].withRenderingMode(renderingMode[i]), for: .normal)
                if responds(to: selectors[i]) {
                    button.addTarget(self, action: selectors[i], for: UIControlEvents.touchUpInside)
                }
                buttons.append(button)
            }

            setNavigationBarRightButtons(buttons)

        return buttons
    }
    
    private func configureButton(image: UIImage,
                                 selectedImage: UIImage?,
                                 renderingMode: UIImageRenderingMode,
                                 selector: Selector,
                                 tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        button.tag = tag
        button.setImage(image.withRenderingMode(renderingMode), for: .normal)
        if let selectedImage = selectedImage {
            button.setImage(selectedImage.withRenderingMode(renderingMode), for: .selected)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.addTarget(self, action: selector, for: UIControlEvents.touchUpInside)
        return button
    }
    
    func setNavigationBarRightButtons(_ buttons: [UIButton], animated: Bool = false) {
        let height: CGFloat = 44

        var x: CGFloat = 0
        
        let items: [UIBarButtonItem] = buttons.flatMap { button in
            guard let icon = button.image(for: .normal) else { return nil }
            
            let buttonWidth = icon.size.width + barButtonsHoritzontalSpacing
            button.frame = CGRect(x: x, y: 0, width: buttonWidth, height: height)
            button.contentHorizontalAlignment = .right
            
            x += buttonWidth
            
            return UIBarButtonItem(customView: button)
        }
        navigationItem.setRightBarButton(nil, animated: animated)
        navigationItem.setRightBarButtonItems(items.reversed(), animated: animated)
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
        completion: (() -> Void)? = nil) {
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
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
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

extension UIViewController {
    func setupForModalWithNonOpaqueBackground() {
        modalPresentationStyle = .overCurrentContext
    }
}

// MARK: - Internal urls presenters

extension UIViewController {
    func openInAppWebViewWith(url: URL) {
        let universalSchemes = ["http", "https"]
        guard let scheme = url.scheme?.lowercased(), universalSchemes.contains(scheme) else { return }
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
