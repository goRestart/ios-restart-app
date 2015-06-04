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
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
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
    
    func setupCellWithPartialProduct(product: Product, indexPath: NSIndexPath) {
        let tag = indexPath.hash
        
        // Name
        nameLabel.text = product.name?.lg_capitalizedWords() ?? ""
        
        // Price
        priceLabel.text = product.formattedPrice()
        
        // Thumb
        if let thumbURL = product.thumbnailURL {
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
        
        // Distance
        distanceLabel.text = product.formattedDistance()
        
        // Status
        if (product.status == .Sold) {
            statusImageView.image = UIImage(named: "label_sold")
        }
        else if let createdAt = product.createdAt {
            if NSDate().timeIntervalSinceDate(createdAt) < 60*60*24 {
                statusImageView.image = UIImage(named: "label_new")
            }
        }
    }
    
    // Configures the cell with the given product for the given index path
    func setupCellWithParseProductObject(product: PFObject, indexPath: NSIndexPath) {
        let tag = indexPath.hash
        
        // Name
        let name = product["name"] as? String ?? ""
        nameLabel.text = name.lg_capitalizedWords()
        
        // Price
        if let price = product["price"] as? Double {
            let currencyCode = product["currency"] as? String ?? Constants.defaultCurrencyCode
            let formattedPrice = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(currencyCode, amount: price)
            priceLabel.text = formattedPrice
        }
        
        // Thumb
        if let imageFile = product[kLetGoProductFirstImageKey] as? PFFile {
            var shouldUseThumbs: Bool
            if let isProcessed = product["processed"] as? Bool {
                shouldUseThumbs = isProcessed
            }
            else {
                shouldUseThumbs = false
            }
            
            // Try downloading thumbnail
            if shouldUseThumbs {
                let thumbURL = ImageHelper.thumbnailURLForProduct(product)
                thumbnailImageView.sd_setImageWithURL(thumbURL, placeholderImage: nil, completed: {
                    [weak self] (image, error, cacheType, url) -> Void in
                   
                    if error == nil {
                        if cacheType == .None {
                            let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                            alphaAnim.fromValue = 0
                            alphaAnim.toValue = 1
                            self?.thumbnailImageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
                        }
                    }
                    // If there's an error then force the download from Parse
                    else {
                        self?.loadImageFromParse(imageFile, tag: tag)
                    }
                })
            }
            
            // Download from Parse
            if !shouldUseThumbs {
                loadImageFromParse(imageFile, tag: tag)
            }
        }
        
        // Distance
        if let productGeoPoint = product["gpscoords"] as? PFGeoPoint {
            distanceLabel.text = distanceStringToGeoPoint(productGeoPoint)
            distanceLabel.hidden = false
        }

        // Status
        if let statusValue = product["status"] as? Int {
            if let status = LetGoProductStatus(rawValue: statusValue) {
                if (status == .Sold) {
                    statusImageView.image = UIImage(named: "label_sold")
                }
                else if product.createdAt != nil &&
                    NSDate().timeIntervalSinceDate(product.createdAt!) < 60*60*24 {
                    statusImageView.image = UIImage(named: "label_new")
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        self.contentView.layer.borderColor = StyleHelper.lineColor.CGColor
        self.contentView.layer.borderWidth = 0.25
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        nameLabel.text = ""
        priceLabel.text = ""
        thumbnailBgColorView.backgroundColor = StyleHelper.productCellBgColor
        thumbnailImageView.image = nil
        distanceLabel.text = ""
        statusImageView.image = nil
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
