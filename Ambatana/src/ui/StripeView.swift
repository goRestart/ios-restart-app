//
//  StripeView.swift
//  LetGo
//
//  Created by Albert Hernández López on 30/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

public class StripeView: UIView {

    public enum StripeViewType {
        case New, Sold
    }
    
    // UI
    @IBOutlet weak var topFoldImageView: UIImageView!
    @IBOutlet weak var rightFoldImageView: UIImageView!
    @IBOutlet weak var stripeImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // Data
    var type: StripeViewType? {
        didSet {
            
        }
    }
    
    // MARK: - Lifecycle
    
    public static func stripeViewWithType(type: StripeViewType) -> StripeView {
        let stripeView = NSBundle.mainBundle().loadNibNamed("StripeView", owner: self, options: nil).first as! StripeView
        return stripeView
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//    }

    private func setupUI() {
    
    }
    
    private func updateUI() {
    
    }
}
