//
//  ProductCell.swift
//  LetGo
//
//  Created by AHL on 13/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
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
    
    // Configures the cell with the given product for the given index path
    func setupCellWithProduct(product: PFObject, indexPath: NSIndexPath) {
        let tag = indexPath.hash
        
        // Name
        let name = product["name"] as? String ?? ""
        nameLabel.text = name
        
        // Price
        if let price = product["price"] as? Double {
            let currencyString = product["currency"] as? String ?? CurrencyManager.sharedInstance.defaultCurrency.iso4217Code
            
            if let currency = CurrencyManager.sharedInstance.currencyForISO4217Symbol(currencyString) {
                priceLabel.text = currency.formattedCurrency(price)
            }
            else { // fallback to just price.
                priceLabel.text = "\(price)"
            }
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
                let thumbURL = NSURL(string: ImageManager.sharedInstance.calculateThumnbailImageURLForProductImage(product.objectId!, imageURL: imageFile.url!))
                
                thumbnailImageView.sd_setImageWithURL(thumbURL, placeholderImage: nil, completed: {
                    [weak self] (image, error, cacheType, url) -> Void in
                    if error == nil {
                        self?.thumbnailImageView.image = image
                    }
                    // If there's an error then force the download from Parse
                    else {
                        shouldUseThumbs = false
                    }
                })
            }
            
            // Download from Parse
            if !shouldUseThumbs {
                imageFile.getDataInBackgroundWithBlock({
                    [weak self] (data, error) -> Void in
                    // tag check to prevent wrong image placement cos' of recycling
                    if (error == nil && self?.tag == tag) {
                        self?.thumbnailImageView.image = UIImage(data: data!)
                    }
                })
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
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        let boldBodyDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody).fontDescriptorWithSymbolicTraits(.TraitBold)
        priceLabel.font = UIFont(descriptor: boldBodyDescriptor!, size: 0.0)
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        nameLabel.text = ""
        priceLabel.text = ""
        thumbnailImageView.image = nil
        distanceLabel.text = ""
        statusImageView.image = nil
    }
    
}
