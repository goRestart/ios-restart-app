//
//  CollectionViewFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public enum CollectionViewFooterStatus {
    case Loading, Error
}

public class CollectionViewFooter: UICollectionReusableView {

    // iVars
    // > UI
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            let hidden: Bool
            switch status {
            case .Loading:
                hidden = false
            case .Error:
                hidden = true
            }
            activityIndicator.hidden = hidden
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
            }
            retryButton.hidden = hidden
        }
    }

    // > Data
    public var retryButtonBlock: (() -> Void)?
    public var status: CollectionViewFooterStatus {
        didSet {
            let activityIndicatorHidden: Bool
            let retryButtonHidden: Bool
            
            switch status {
            case .Loading:
                activityIndicatorHidden = false
                retryButtonHidden = true
            case .Error:
                activityIndicatorHidden = true
                retryButtonHidden = false
            }
            
            if let activityIndicator = activityIndicator {
                activityIndicator.hidden = activityIndicatorHidden
            }
            if let retryButton = retryButton {
                retryButton.hidden = retryButtonHidden
            }
        }
    }
    
    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        self.status = .Loading
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.status = .Loading
        super.init(coder: aDecoder)
    }
    // MARK: - Internal methods
    
    @IBAction func retryButtonPressed(sender: UIButton) {
        retryButtonBlock?()
    }
}
