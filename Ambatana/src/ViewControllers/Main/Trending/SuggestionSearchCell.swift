//
//  SuggestionSearchCell.swift
//  LetGo
//
//  Created by Eli Kohen on 07/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class SuggestionSearchCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var suggestionText: UILabel!

    static let cellHeight: CGFloat = 44
    let labelFont = UIFont.systemFont(size: 17)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        setAccessibilityIds()
        suggestionText.font = labelFont
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .suggestionSearchCell
        suggestionText.accessibilityId = .suggestionSearchCellSuggestionText
    }
}
