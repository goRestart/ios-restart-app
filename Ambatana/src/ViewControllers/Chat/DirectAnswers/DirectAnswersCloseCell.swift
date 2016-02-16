//
//  DirectAnswersCloseCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class DirectAnswersCloseCell: UICollectionViewCell, ReusableCell {

    private static let cellHeight: CGFloat = 32

    static func size() -> CGSize {
        return CGSize(width: cellHeight, height: cellHeight)
    }

    static func reusableID() -> String {
        return "DirectAnswersCloseCell"
    }

    override func awakeFromNib() {
    }
}
