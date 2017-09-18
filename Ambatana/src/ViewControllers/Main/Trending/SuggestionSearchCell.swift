//
//  SuggestionSearchCell.swift
//  LetGo
//
//  Created by Eli Kohen on 07/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class SuggestionSearchCell: UITableViewCell, ReusableCell {
    static let cellHeight: CGFloat = 44
    
    let suggestionText = UILabel()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAccessibilityIds()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(suggestionText)
        
        suggestionText.layout(with: contentView)
            .leading(by: Metrics.margin)
            .trailing()
            .top()
            .bottom()
    }

    private func setAccessibilityIds() {
        accessibilityId = .suggestionSearchCell
        suggestionText.accessibilityId = .suggestionSearchCellSuggestionText
    }
}
