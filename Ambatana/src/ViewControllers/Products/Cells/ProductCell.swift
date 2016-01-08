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
    var cellWidth: CGFloat
}

class ProductCell: UICollectionViewCell, ReusableCell {

    @IBOutlet weak var cellContent: UIView!
    @IBOutlet weak var cellContentHeight: NSLayoutConstraint!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var thumbnailBgColorView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var priceGradientView: UIView!
    
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

    func setCellWidth(width: CGFloat) {
        if let sublayers = priceGradientView.layer.sublayers {
            let gradientBounds = CGRect(x: 0, y: 0, width: width, height: priceGradientView.height)
            for sublayer in sublayers {
                sublayer.frame = gradientBounds
            }
        }
    }


    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        cellContent.layer.cornerRadius = StyleHelper.defaultCornerRadius
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.0,0.4],
            locations: [0.0,1.0])
        shadowLayer.frame = priceGradientView.bounds
        priceGradientView.layer.addSublayer(shadowLayer)
        let rotation = CGFloat(M_PI_4)
        stripeLabel.transform = CGAffineTransformMakeRotation(rotation)
//        cellContentHeight.constant = 0
    }

    // Resets the UI to the initial state
    private func resetUI() {
        priceLabel.text = ""
        thumbnailBgColorView.backgroundColor = StyleHelper.productCellBgColor
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
    }
    
}
