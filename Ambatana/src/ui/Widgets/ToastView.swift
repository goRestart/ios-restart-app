//
//  ToastView.swift
//  LetGo
//
//  Created by Albert Hernández López on 13/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public class ToastView: UIView {

    static let standardHeight: CGFloat = 33

    // iVars
    // > UI
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var labelTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelRightMarginConstraint: NSLayoutConstraint!

    // > Data
    public var title: String = "" {
        didSet {
            if let label = label {
                label.text = title
            }
        }
    }
    
    // MARK: - Lifecycle
    
    public static func toastView() -> ToastView? {
        return NSBundle.mainBundle().loadNibNamed("ToastView", owner: self, options: nil).first as? ToastView
    }
    
    public override func intrinsicContentSize() -> CGSize {
        var size = label.intrinsicContentSize()
        size.height += labelTopMarginConstraint.constant + labelBottomMarginConstraint.constant
        size.width += labelLeftMarginConstraint.constant + labelRightMarginConstraint.constant
        return size
    }
}
