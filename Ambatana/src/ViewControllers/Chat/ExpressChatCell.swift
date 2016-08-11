//
//  ExpressChatCell.swift
//  LetGo
//
//  Created by Dídac on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ExpressChatCell: UICollectionViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override var selected: Bool {
        didSet {
            selectedImageView.image = selected ? UIImage(named: "checkbox_selected") : nil
            selectedImageView.layer.borderWidth = selected ? 0 : 2
        }
    }

    func configureCellWithImage(imageUrl: NSURL, price: String) {
        selectedImageView.layer.borderColor = UIColor.whiteColor().CGColor
        priceLabel.text = price

        layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        productImageView.lg_setImageWithURL(imageUrl) { [weak self] (result, _ ) in
            if let image = result.value?.image {
                self?.productImageView.image = image
            }
        }
    }
}
