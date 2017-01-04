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
    var shadowLayer: CALayer?


    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientView()
    }

    override var isSelected: Bool {
        didSet {
            selectedImageView.image = isSelected ? UIImage(named: "checkbox_selected_round") : nil
            selectedImageView.layer.borderWidth = isSelected ? 0 : 2
        }
    }

    func configureCellWithTitle(_ title: String, imageUrl: URL, price: String) {
        selectedImageView.layer.borderColor = UIColor.white.cgColor
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

        setupAccessibilityIds()

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func setupGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        shadowLayer = CAGradientLayer.gradientWithColor(UIColor.black, alphas:[0, 0.4], locations: [0, 1])
        if let shadowLayer = shadowLayer {
            shadowLayer.frame = gradientView.bounds
            gradientView.layer.insertSublayer(shadowLayer, at: 0)
        }
    }

    func setupAccessibilityIds() {
        self.accessibilityId = .ExpressChatCell
        self.titleLabel.accessibilityId = .ExpressChatCellProductTitle
        self.priceLabel.accessibilityId = .ExpressChatCellProductPrice
        self.selectedImageView.accessibilityId = .ExpressChatCellTickSelected
    }
}
