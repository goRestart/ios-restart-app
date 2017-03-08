//
//  PostProductTabsFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PostProductTabsFooter: UIView {
    
    
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
}


// MARK: - PostProductFooter

extension PostProductTabsFooter: PostProductFooter {
    func updateCameraButton(isHidden: Bool) {
    }
    
    func update(scroll: CGFloat) {
    }
}


// MARK: - Private methods

fileprivate extension PostProductTabsFooter {
    func setupUI() {
    }
    
    func setupAccessibilityIds() {
    }
    
    func setupLayout() {
    }
}
