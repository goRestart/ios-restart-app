//
//  ProductCell.swift
//  LetGo
//
//  Created by AHL on 13/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
import pop
import UIKit

struct ProductCellData {
    var title: String?
    var price: String?
    var thumbUrl: NSURL?
    var status: ProductStatus
    var date: NSDate?
}

class ProductCell: UICollectionViewCell, ReusableCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var thumbnailBgColorView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    // Stripe
    @IBOutlet weak var stripeImageView: UIImageView!
    @IBOutlet weak var stripeLabel: UILabel!

    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    
    // MARK: - Static methods

    static func reusableID() -> String {
        return "ProductCell"
    }


    // MARK: - Public / internal methods

    func setImageUrl(imageUrl: NSURL) {
        thumbnailImageView.sd_setImageWithURL(imageUrl, placeholderImage: nil, completed: {
            [weak self] (image, error, cacheType, url) -> Void in
            if cacheType == .None {
                let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                alphaAnim.fromValue = 0
                alphaAnim.toValue = 1
                self?.thumbnailImageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
            }
            })
    }

    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = StyleHelper.defaultCornerRadius
        thumbnailBgColorView.layer.cornerRadius = StyleHelper.defaultCornerRadius
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        priceLabel.text = ""
        thumbnailBgColorView.backgroundColor = StyleHelper.productCellBgColor
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        let rotation = CGFloat(M_PI_4)
        stripeLabel.transform = CGAffineTransformMakeRotation(rotation)
    }
    
}
