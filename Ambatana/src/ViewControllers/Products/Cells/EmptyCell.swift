//
//  EmptyCell.swift
//  LetGo
//
//  Created by Dídac on 10/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class EmptyCell: UICollectionViewCell, ReusableCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
}
