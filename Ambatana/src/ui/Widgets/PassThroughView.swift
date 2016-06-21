//
//  PassThroughView.swift
//  LetGo
//
//  Created by Eli Kohen on 17/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class PassThroughView: UIView {

    var onTouch: (()->Void)?

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        onTouch?()
        return nil
    }
}
