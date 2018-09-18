//
//  AppEventsManager.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 9/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class AppEventsManager {

    static let sharedInstance: AppEventsManager = AppEventsManager()

    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable

    convenience init() {
         self.init(tracker: TrackerProxy.sharedInstance,
                   featureFlags: FeatureFlags.sharedInstance)
    }

    init(tracker: Tracker, featureFlags: FeatureFlaggeable) {
        self.tracker = tracker
        self.featureFlags = featureFlags
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidTakeScreenshot),
                                               name: .UIApplicationUserDidTakeScreenshot,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func userDidTakeScreenshot(_ notification: Notification) {
        defer { trackScreenshotEvent() }
        guard featureFlags.shareAfterScreenshot.isActive else { return }
        guard let topVC = UIApplication.getTopMostViewController() else { return }
        guard let image = UIApplication.shared.takeWindowSnapshot() else { return }
        let shareScreenshotAssembly = LGShareScreenshotBuilder.modal(root: topVC)
        let shareScreenshotVC = shareScreenshotAssembly.buildShareScreenshot(screenshotImage: image)
        topVC.present(shareScreenshotVC, animated: true, completion: nil)
    }
    

    // MARK: - Tracking
    
    private func trackScreenshotEvent() {
        let event = TrackerEvent.userDidTakeScreenshot()
        tracker.trackEvent(event)
    }
}

fileprivate extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}

fileprivate extension UIViewController {
    func showShareScreenshot(viewImage: UIImage) {
        let vm = ShareScreenshotViewModel(screenshotImage: viewImage)
        let vc = ShareScreenshotViewController(viewModel: vm)
        present(vc, animated: true, completion: nil)
    }
}

fileprivate extension UIApplication {
    func takeWindowSnapshot() -> UIImage? {
        return keyWindow?.layer.takeSnapshot()
    }
}

fileprivate extension CALayer {
    func takeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
