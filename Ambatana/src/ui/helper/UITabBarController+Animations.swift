//
//  UITabBarController+Animations.swift
//  LetGo
//
//  Created by Eli Kohen on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

let UITabBarControllerHideShowBarDuration: CGFloat = UINavigationControllerHideShowBarDuration

extension UITabBarController {

    var isTabBarHidden: Bool { return tabBar.frame.origin.y >= self.view.frame.maxY }

    /**
    This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
    */
    @objc func setTabBarHidden(_ hidden:Bool, animated:Bool, completion: ((Bool) -> (Void))? = nil) {
        // bail if the current state matches the desired state
        if (isTabBarHidden == hidden) { return }

        // get a frame calculation ready
        let frame = tabBar.frame
        let height = frame.size.height
        let offsetY = (hidden ? height : -height)

        // zero duration means no animation
        let duration: TimeInterval = (animated ? TimeInterval(UITabBarControllerHideShowBarDuration) : 0.0)

        //  animate the tabBar

        prepareLayoutForTabBarAnimation()
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
            self?.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
            self?.tabBar.layoutIfNeeded()
            }, completion: completion)
    }

    private func prepareLayoutForTabBarAnimation() {
        // ☢️☢️ View does not update when chaning tabs without animation (from tabbar hidden to not hidden)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

}
