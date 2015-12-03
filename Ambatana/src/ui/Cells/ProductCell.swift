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

class ProductCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
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
    
    // MARK: - Public / internal methods
    
    func setupCellWithProductName(name: String?, price: String, thumbnail: File?, status: ProductStatus,
        creationDate: NSDate?) {
            // Name
            nameLabel.text = name?.lg_capitalizedWords() ?? ""
            
            // Price
            priceLabel.text = price //product.formattedPrice()
            
            // Thumb
            if let thumbURL = thumbnail?.fileURL {
                thumbnailImageView.sd_setImageWithURL(thumbURL, placeholderImage: nil, completed: {
                    [weak self] (image, error, cacheType, url) -> Void in
                    if cacheType == .None {
                        let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                        alphaAnim.fromValue = 0
                        alphaAnim.toValue = 1
                        self?.thumbnailImageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
                    }
                    })
            }
            
            // Status (stripe)
            switch status {
            case .Sold, .SoldOld:
                stripeImageView.image = UIImage(named: "stripe_sold")
                stripeLabel.text = LGLocalizedString.productListItemSoldStatusLabel
                
            case .Pending, .Approved, .Discarded, .Deleted:
                if let createdAt = creationDate {
                    if NSDate().timeIntervalSinceDate(createdAt) < 60*60*24 {
                        stripeImageView.image = UIImage(named: "stripe_new")
                        stripeLabel.text = LGLocalizedString.productListItemNewStatusLabel
                    }
                }
            }
    }
    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        self.contentView.layer.borderColor = StyleHelper.lineColor.CGColor
        self.contentView.layer.borderWidth = 0.3
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        nameLabel.text = ""
        priceLabel.text = ""
        thumbnailBgColorView.backgroundColor = StyleHelper.productCellBgColor
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        let rotation = CGFloat(M_PI_4)
        stripeLabel.transform = CGAffineTransformMakeRotation(rotation)
    }
    
    // TODO: Remove this method and load straight using SDWebImage or better, should be refactored with new API call
    private func loadImageFromParse(imageFile: PFFile, tag: Int) {
        imageFile.getDataInBackgroundWithBlock({
            [weak self] (data, error) -> Void in
            // tag check to prevent wrong image placement cos' of recycling
            if (error == nil && self?.tag == tag) {
                self?.thumbnailImageView.image = UIImage(data: data!)

                let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                alphaAnim.fromValue = 0
                alphaAnim.toValue = 1
                self?.thumbnailImageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
            }
        })
    }
}
