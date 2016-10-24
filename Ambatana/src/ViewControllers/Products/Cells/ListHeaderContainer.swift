//
//  ListHeaderContainer.swift
//  LetGo
//
//  Created by Eli Kohen on 24/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ListHeaderContainer: UICollectionReusableView, ReusableCell {
    @IBOutlet weak var containerView: UIView!

    func clear() {
        containerView.subviews.forEach { $0.removeFromSuperview() }
    }
}
