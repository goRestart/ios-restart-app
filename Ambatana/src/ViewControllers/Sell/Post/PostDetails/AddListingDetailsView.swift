//
//  File.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

struct ListingDetails {
    let title: String
    let value: String
    let action: () -> ()
}

class AddListingDetailsView: UIView {
    private let title = ""
    private let titleLabel = UILabel()
    private let ProgressView = ProgressView()
    private let listingDetails: [listingDetails]
    private let doneButton: UIButton
    
    // MARK: - Lifecycle
    
    init(withTitle title: String, listingDetails: [listingDetails]) {
        self.title = title
        self.listingDetails = listingDetails
        
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateUI()
    }
    
    // MARK: 
}
