//
//  PassthroughScrollView.swift
//  LetGo
//
//  Created by Facundo Menzella on 08/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

// thanks to https://github.com/52inc/Pulley/blob/master/PulleyLib/PulleyPassthroughScrollView.swift

import Foundation

protocol PassthroughScrollViewDelegate: class {

    func shouldTouchPassthroughScrollView(scrollView: PassthroughScrollView, point: CGPoint, with event: UIEvent?) -> Bool
    func viewToReceiveTouch(scrollView: PassthroughScrollView) -> UIView
}

class PassthroughScrollView: UIScrollView {

    weak var touchDelegate: PassthroughScrollViewDelegate?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if let touchDel = touchDelegate {
            if touchDel.shouldTouchPassthroughScrollView(scrollView: self, point: point, with: event) {
                return touchDel.viewToReceiveTouch(scrollView: self)
                    .hitTest(touchDel.viewToReceiveTouch(scrollView: self).convert(point, from: self), with: event)
            }
        }

        return super.hitTest(point, with: event)
    }
}
