//
//  PostListingFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

protocol PostListingFooter {
    var galleryButton: UIButton { get }
    var cameraButton: UIButton { get }
    var isHidden: Bool { get set }
    func update(scroll: CGFloat)
}