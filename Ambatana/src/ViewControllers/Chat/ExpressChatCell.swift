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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!


//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        setupGradientView()
//    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupGradientView()
    }

    override var selected: Bool {
        didSet {
            selectedImageView.image = selected ? UIImage(named: "checkbox_selected_round") : nil
            selectedImageView.layer.borderWidth = selected ? 0 : 2
        }
    }

    func configureCellWithTitle(title: String, imageUrl: NSURL, price: String) {
        selectedImageView.layer.borderColor = UIColor.whiteColor().CGColor
        selectedImageView.layer.cornerRadius = selectedImageView.height/2
        priceLabel.text = price
        titleLabel.text = title

        layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        productImageView.image = UIImage(named: "product_placeholder")
        productImageView.lg_setImageWithURL(imageUrl) { [weak self] (result, _ ) in
            if let image = result.value?.image {
                self?.productImageView.image = image
            } else {
                self?.productImageView.image = UIImage(named: "product_placeholder")
            }
        }
    }

    private func setupGradientView() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0, 0.4], locations: [0, 1])
        shadowLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(shadowLayer, atIndex: 0)
    }
}
