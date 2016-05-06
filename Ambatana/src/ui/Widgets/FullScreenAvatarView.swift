//
//  FullScreenAvatarView.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

final class FullScreenAvatarView: UIView {
    @IBOutlet weak var avatarImageView: UIImageView!

    func setImageWithURL(url: NSURL, placeholderImage: UIImage?) {
        avatarImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage)
    }
}
