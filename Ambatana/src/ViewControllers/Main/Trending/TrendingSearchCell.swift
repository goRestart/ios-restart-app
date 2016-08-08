//
//  TrendingSearchCell.swift
//  LetGo
//
//  Created by Eli Kohen on 07/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class TrendingSearchCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var trendingText: UILabel!

    static let cellHeight: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
    }
}
