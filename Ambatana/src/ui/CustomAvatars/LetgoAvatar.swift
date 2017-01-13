//
//  LetgoAvatar.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class LetgoAvatar {
    static func avatarWithID(_ id: String?, name: String?) -> UIImage? {
        let color = UIColor.avatarColorForString(id)
        return LetgoAvatar.avatarWithColor(color, name: name)
    }

    static func avatarWithColor(_ color: UIColor, name: String?) -> UIImage? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = color

        let label = UILabel(frame: view.bounds)
        if let c = name?.specialCharactersRemoved.characters.first {
                label.text = String(c).capitalized
        }
        label.font = UIFont.avatarFont
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        view.addSubview(label)

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return UIImage() }
        view.layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
