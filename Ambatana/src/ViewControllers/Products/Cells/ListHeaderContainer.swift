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

        var views = [String: AnyObject]()
        views["header"] = view
        var metrics = [String: AnyObject]()
        metrics["height"] = height as AnyObject?
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[header]-0-|",
            options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[header(height)]-0-|",
            options: [], metrics: metrics, views: views))

        totalHeight += height
    }

    func clear() {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        totalHeight = 0
    }
}
