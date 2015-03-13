//
//  ProductCell.swift
//  Ambatana
//
//  Created by AHL on 13/3/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        let boldBodyDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody).fontDescriptorWithSymbolicTraits(.TraitBold)
        priceLabel.font = UIFont(descriptor: boldBodyDescriptor, size: 0.0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        nameLabel.text = ""
        priceLabel.text = ""
    }
    
    func setupCellWithProduct(product: PFObject) {

        // name
        let name = product["name"] as? String ?? ""
        nameLabel.text = name
        
        // price
        if let price = product["price"] as? Double {
            let currencyString = product["currency"] as? String ?? CurrencyManager.sharedInstance.defaultCurrency.iso4217Code
            
            if let currency = CurrencyManager.sharedInstance.currencyForISO4217Symbol(currencyString) {
                priceLabel.text = currency.formattedCurrency(price)
            }
            else { // fallback to just price.
                priceLabel.text = "\(price)"
            }
        }
        
        // thumb
        if let imageFile = product[kAmbatanaProductFirstImageKey] as? PFFile {
            var shouldUseThumbs: Bool
            if let isProcessed = product["processed"] as? Bool {
                shouldUseThumbs = isProcessed
            }
            else {
                shouldUseThumbs = false
            }
            
            if shouldUseThumbs { // can we try to download the image from the generated thumbnail?
                let thumbnailURL = ImageManager.sharedInstance.calculateThumnbailImageURLForProductImage(product.objectId, imageURL: imageFile.url)
                ImageManager.sharedInstance.retrieveImageFromURLString(thumbnailURL, completion: { (success, image) -> Void in
                    if success {
                        self.thumbnailImageView.image = image
                        self.thumbnailImageView.contentMode = .ScaleAspectFill
                        self.thumbnailImageView.clipsToBounds = true
                    } else { // failure, fallback to parse PFFile for the image.
                        self.retrieveImageFile(imageFile, andAssignToImageView: self.thumbnailImageView)
                    }
                })
            }
            else { // stick to the Parse big fat old image...
                self.retrieveImageFile(imageFile, andAssignToImageView: thumbnailImageView)
            }
        }
        
//        // distance
//        // TODO: Check if there's a better way of getting the distance in km. Maybe in the query?
//        if let distanceLabel = cell.viewWithTag(4) as? UILabel {
//            if let productGeoPoint = productObject["gpscoords"] as? PFGeoPoint {
//                let distance = productGeoPoint.distanceInKilometersTo(PFUser.currentUser()["gpscoords"] as PFGeoPoint)
//                if distance > 1.0 { distanceLabel.text = NSString(format: "%.1fK", distance) }
//                else {
//                    let metres: Int = Int(distance * 1000)
//                    if metres > 1 { distanceLabel.text = NSString(format: "%dM", metres) }
//                    else { distanceLabel.text = translate("here") }
//                }
//                distanceLabel.hidden = false
//            } else { distanceLabel.hidden = true }
//        }
//        
//        // status
//        if let tagView = cell.viewWithTag(5) as? UIImageView { // product status
//            if let statusValue = productObject["status"] as? Int {
//                if let status = ProductStatus(rawValue: productObject["status"].integerValue) {
//                    if (status == .Sold) {
//                        tagView.image = UIImage(named: "label_sold")
//                        tagView.hidden = false
//                    } else if productObject.createdAt != nil && NSDate().timeIntervalSinceDate(productObject.createdAt!) < 60*60*24 {
//                        tagView.image = UIImage(named: "label_new")
//                        tagView.hidden = false
//                    } else {
//                        tagView.hidden = true
//                    }
//                } else { tagView.hidden = true }
//            } else { tagView.hidden = true }
//        }

    }
    
    func retrieveImageFile(imageFile: PFFile, andAssignToImageView imageView: UIImageView) {
        ImageManager.sharedInstance.retrieveImageFromParsePFFile(imageFile, completion: { (success, image) -> Void in
            if success {
                imageView.image = image
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
            }
            }, andAddToCache: true)
    }
    
}


