//
//  PostCategoryDetailTableView.swift
//  LetGo
//
//  Created by Nestor on 12/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

enum CategoryDetailSelectedInfo {
    case index(index: Int)
    case custom(string: String) // for 'Others' options
}

final class PostCategoryDetailTableView: UIView {
    
    let titles: [String]
    let selectedIndex: Int?
    
    // MARK: - Lifecycle
    
    init(withTitles titles: [String], selectedIndex: Int?) {
        self.titles = titles
        self.selectedIndex = selectedIndex
        
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        
    }
    
    private func setupLayout() {
        
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
}
