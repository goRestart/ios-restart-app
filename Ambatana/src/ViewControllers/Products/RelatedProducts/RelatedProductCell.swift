//
//  RelatedProductCell.swift
//  LetGo
//
//  Created by Eli Kohen on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class RelatedProductCell: UICollectionViewCell, ReusableCell {

    @IBOutlet weak var productImage: UIImageView!

    override var highlighted: Bool {
        didSet {
            productImage.alpha = highlighted ? 0.8 : 1.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    func setupWithImageUrl(url: NSURL?) {
        let placeholder = UIImage(named: "product_placeholder")
        guard let url = url else {
            productImage.image = placeholder
            return
        }
        productImage.lg_setImageWithURL(url, placeholderImage: placeholder, completion: nil)
    }

    private func setupUI() {
        productImage.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
    }
}
