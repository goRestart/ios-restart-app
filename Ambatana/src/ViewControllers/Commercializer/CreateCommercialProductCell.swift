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
        imageView.layer.cornerRadius = StyleHelper.defaultCornerRadius
        imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        imageView.backgroundColor = StyleHelper.productCellImageBgColor
    }
}