//
//  SellProductCell.swift
//  LetGo
//
//  Created by Dídac on 27/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SellProductCell: UICollectionViewCell {

    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var activity : UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupEmptyCell() {
        iconImageView.image = UIImage()
        self.label.hidden = true
        self.activity.hidden = true
        self.activity.stopAnimating()
        self.imageView.image = UIImage()
        self.backgroundColor = StyleHelper.emptypictureCellBackgroundColor
    }
    
    func setupLoadingCell() {
        iconImageView.image = UIImage()
        self.label.hidden = true
        self.activity.hidden = false
        self.activity.startAnimating()
        self.imageView.image = UIImage()

    }
    
    func setupCellWithImage(image: UIImage) {
        iconImageView.image = UIImage()
        self.label.hidden = true
        self.activity.hidden = true
        self.activity.stopAnimating()
        imageView.image = image
    }

    func setupAddPictureCell() {
        self.label.hidden = false
        label.text = NSLocalizedString("sell_picture_label", comment: "")
        self.activity.hidden = true
        iconImageView.image = UIImage(named: "button_icon_sell")
        imageView.image = UIImage()
        self.backgroundColor = UIColor.whiteColor()
    }

}
