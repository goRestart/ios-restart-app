//
//  PostProductPostFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PostProductPostFooter: UIView {
    
    
    // MARK: - Lifecycle
    
    init() {
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
        updateUI()
    }
}


// MARK: - Private methods

fileprivate extension PostProductPostFooter {
    func setupUI() {
    }
    
    func setupAccessibilityIds() {
    }
    
    func setupLayout() {
    }
    
    func updateUI() {
    }
}
