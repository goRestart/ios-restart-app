//
//  LetgoAvatar.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class LetgoAvatar {
    static func avatarWithID(id: String?, name: String?) -> UIImage {
        let color = StyleHelper.avatarColorForString(id)
        return LetgoAvatar.avatarWithColor(color, name: name)
    }

    static func avatarWithColor(color: UIColor, name: String?) -> UIImage {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = color

        let label = UILabel(frame: view.bounds)

        if let c = name?.characters.first {
            label.text = String(c).capitalizedString
        }
        label.font = StyleHelper.avatarFont
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Center
        view.addSubview(label)

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}