//
//  ToastView.swift
//  LetGo
//
//  Created by Albert Hernández López on 13/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class ToastView: UIView {

    static let standardHeight: CGFloat = 33

    // iVars
    // > UI
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var labelTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelRightMarginConstraint: NSLayoutConstraint!

    // > Data
    open var title: String = "" {
        didSet {
            if let label = label {
                label.text = title
            }
        }
    }
    
    // MARK: - Lifecycle
    
    open static func toastView() -> ToastView? {
        return Bundle.main.loadNibNamed("ToastView", owner: self, options: nil)?.first as? ToastView
    }
    
    open override var intrinsicContentSize : CGSize {
        var size = label.intrinsicContentSize
        size.height += labelTopMarginConstraint.constant + labelBottomMarginConstraint.constant
        size.width += labelLeftMarginConstraint.constant + labelRightMarginConstraint.constant
        return size
    }
}
