//
//  UITabBarController+Animations.swift
//  LetGo
//
//  Created by Eli Kohen on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

extension UITabBarController {

    /**
    This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
    */
    func setTabBarHidden(hidden:Bool, animated:Bool, completion: ((Bool) -> (Void))? = nil) {

        // bail if the current state matches the desired state
        if (tabBarHidden() == hidden) { return }

        // get a frame calculation ready
        let frame = tabBar.frame
        let height = frame.size.height
        let offsetY = (hidden ? height : -height)

        // zero duration means no animation
        let duration : NSTimeInterval = (animated ? NSTimeInterval(UINavigationControllerHideShowBarDuration) : 0.0)

        //  animate the tabBar
        UIView.animateWithDuration(duration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tabBar.frame = CGRectOffset(frame, 0, offsetY)
            self?.view.layoutIfNeeded()
        }

        UIView.animateWithDuration(duration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tabBar.frame = CGRectOffset(frame, 0, offsetY)
            self?.view.layoutIfNeeded()
        }, completion: completion)
    }

    func tabBarHidden() -> Bool {
        return tabBar.frame.origin.y >= CGRectGetMaxY(self.view.frame)
    }
    
}