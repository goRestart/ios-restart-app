//
//  CollectionViewFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public enum CollectionViewFooterStatus {
    case Loading, Error, LastPage
}

public class CollectionViewFooter: UICollectionReusableView, ReusableCell {

    // iVars
    // > UI
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            let animating: Bool
            switch status {
            case .Loading:
                animating = true
            case .Error:
                animating = false
            case .LastPage:
                animating = false
            }
            if animating {
                activityIndicator.startAnimating()
            }
            else {
                activityIndicator.stopAnimating()
            }
        }
    }
    @IBOutlet weak var retryButton: UIButton! {
        didSet {
            let hidden: Bool
            switch status {
            case .Loading:
                hidden = true
            case .Error:
                hidden = false
            case .LastPage:
                hidden = true
            }
            retryButton.hidden = hidden
            retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, forState: .Normal)
        }
    }

    // > Data
    public var retryButtonBlock: (() -> Void)?
    public var status: CollectionViewFooterStatus {
        didSet {
            let activityIndicatorAnimating: Bool
            let retryButtonHidden: Bool
            
            switch status {
            case .Loading:
                activityIndicatorAnimating = true
                retryButtonHidden = true
            case .Error:
                activityIndicatorAnimating = false
                retryButtonHidden = false
            case .LastPage:
                activityIndicatorAnimating = false
                retryButtonHidden = true
            }
            
            if let activityIndicator = activityIndicator {
                if activityIndicatorAnimating {
                    activityIndicator.startAnimating()
                }
                else {
                    activityIndicator.stopAnimating()
                }
            }
            if let retryButton = retryButton {
                retryButton.hidden = retryButtonHidden
            }
        }
    }
    
    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        self.status = .LastPage
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.status = .LastPage
        super.init(coder: aDecoder)
    }
    // MARK: - Internal methods
    
    @IBAction func retryButtonPressed(sender: UIButton) {
        retryButtonBlock?()
    }
}
