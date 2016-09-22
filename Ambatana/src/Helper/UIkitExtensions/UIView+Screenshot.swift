//
//  UIView+Screenshot.swift
//  LetGo
//
//  Created by Eli Kohen on 25/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIView {
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
