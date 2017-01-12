//
//  CollectionViewFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

enum CollectionViewFooterStatus {
    case loading, error, lastPage
}

class CollectionViewFooter: UICollectionReusableView, ReusableCell {

    // iVars
    // > UI
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            let animating: Bool
            switch status {
            case .loading:
                animating = true
            case .error:
                animating = false
            case .lastPage:
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
            case .loading:
                hidden = true
            case .error:
                hidden = false
            case .lastPage:
                hidden = true
            }
            retryButton.isHidden = hidden
            retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, for: .normal)
        }
    }

    // > Data
    var retryButtonBlock: (() -> Void)?
    var status: CollectionViewFooterStatus {
        didSet {
            let activityIndicatorAnimating: Bool
            let retryButtonHidden: Bool
            
            switch status {
            case .loading:
                activityIndicatorAnimating = true
                retryButtonHidden = true
            case .error:
                activityIndicatorAnimating = false
                retryButtonHidden = false
            case .lastPage:
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
                retryButton.isHidden = retryButtonHidden
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        self.status = .lastPage
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.status = .lastPage
        super.init(coder: aDecoder)
    }
    // MARK: - Internal methods
    
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        retryButtonBlock?()
    }
}
