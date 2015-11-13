//
//  NoNetworkView.swift
//  LetGo
//
//  Created by Albert Hernández López on 13/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public class NoNetworkView: UIView {

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
    
    public static func noNetworkView() -> NoNetworkView? {
        return NSBundle.mainBundle().loadNibNamed("NoNetworkView", owner: self, options: nil).first as? NoNetworkView
    }
    
    public override func intrinsicContentSize() -> CGSize {
        var size = label.intrinsicContentSize()
        size.height += labelTopMarginConstraint.constant + labelBottomMarginConstraint.constant
        size.width += labelLeftMarginConstraint.constant + labelRightMarginConstraint.constant
        return size
    }
}
