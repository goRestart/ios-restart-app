//
//  DirectAnswersCloseCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class DirectAnswersCloseCell: UICollectionViewCell, ReusableCell {

    static let reusableID = "DirectAnswersCloseCell"
    private static let cellHeight: CGFloat = 32

    @IBOutlet weak var image: UIImageView!

    static func size() -> CGSize {
        return CGSize(width: cellHeight, height: cellHeight)
    }

    override func awakeFromNib() {
    }

    func setupWith(style: DirectAnswersStyle) {
        switch style {
        case .dark:
            image.image = UIImage(named: "direct_answers_close")
        case .light:
            image.image = UIImage(named: "ic_post_close")
        }
    }
}
