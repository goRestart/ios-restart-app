//
//  SuggestionSearchCell.swift
//  LetGo
//
//  Created by Eli Kohen on 07/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class SuggestionSearchCell: UITableViewCell, ReusableCell {
    static let estimatedHeight: CGFloat = 44
    
    let suggestionText = UILabel()
    let categoryLabel = UILabel()
    
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
        
        let subviews = [suggestionText, categoryLabel]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        contentView.addSubviews(subviews)
        
        suggestionText.layout(with: contentView)
            .leading(by: Metrics.margin)
            .trailing()
            .top(by: Metrics.shortMargin)
        
        categoryLabel.layout(with: suggestionText).below()
        categoryLabel.layout(with: contentView)
            .leading(by: Metrics.margin)
            .trailing()
            .bottom(by: -Metrics.shortMargin)
    }

    private func setAccessibilityIds() {
        accessibilityId = .suggestionSearchCell
        suggestionText.accessibilityId = .suggestionSearchCellSuggestionText
        categoryLabel.accessibilityId = .suggestionSearchCellCategory
    }
}
