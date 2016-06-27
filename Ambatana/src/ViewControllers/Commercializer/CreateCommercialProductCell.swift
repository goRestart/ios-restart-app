//
//  CreateCommercialProductCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class CreateCommercialProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        imageView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        imageView.backgroundColor = UIColor.placeholderBackgroundColor()
    }
}
