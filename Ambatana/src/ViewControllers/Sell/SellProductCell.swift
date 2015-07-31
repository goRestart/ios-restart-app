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
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var activity : UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupEmptyCell() {
        self.label.hidden = true
        self.activity.hidden = true
        self.activity.stopAnimating()
        self.imageView.image = UIImage()
        self.backgroundColor = StyleHelper.emptypictureCellBackgroundColor
    }
    
    func setupLoadingCell() {
        self.label.hidden = true
        self.activity.hidden = false
        self.activity.startAnimating()
        self.imageView.image = UIImage()

    }
    
    func setupCellWithImage(image: UIImage) {
        self.label.hidden = true
        self.activity.hidden = true
        self.activity.stopAnimating()
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }

    func setupAddPictureCell() {
        self.label.hidden = false
        label.text = NSLocalizedString("sell_picture_label", comment: "")
        self.activity.hidden = true
        imageView.image = UIImage(named: "button_icon_sell")
        imageView.contentMode = UIViewContentMode.Center
        self.backgroundColor = UIColor.whiteColor()

    }

}
