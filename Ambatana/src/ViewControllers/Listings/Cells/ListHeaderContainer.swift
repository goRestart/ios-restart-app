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

    var totalHeight: CGFloat = 0

    func getHeader(_ tag: Int) -> UIView? {
        for view in containerView.subviews {
            if view.tag == tag {
                return view
            }
        }
        return nil
    }

    func addHeader(_ view: UIView, height: CGFloat) {
        guard getHeader(view.tag) == nil else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        
        view.layout(with: containerView).fillHorizontal().top(by: totalHeight)
        view.layout().height(height)
        totalHeight += height
    }

    func clear() {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        totalHeight = 0
    }
}
