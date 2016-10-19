//
//  UIButton+ImageRight.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIButton {
    func setImageRight() {
        // http://stackoverflow.com/questions/7100976/how-do-i-put-the-image-on-the-right-side-of-the-text-in-a-uibutton
        if #available(iOS 9.0, *) {
            semanticContentAttribute = .ForceRightToLeft
        } else {
            transform = CGAffineTransformMakeScale(-1, 0)
            titleLabel?.transform = CGAffineTransformMakeScale(-1, 0)
            imageView?.transform = CGAffineTransformMakeScale(-1, 0)
        }

        titleEdgeInsets = UIEdgeInsets(top: 0, left: -titleEdgeInsets.right, bottom: 0, right: -titleEdgeInsets.left)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: titleEdgeInsets.right, bottom: 0, right: titleEdgeInsets.left)
    }
}
