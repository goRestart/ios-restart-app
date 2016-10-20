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
        self.backgroundColor = UIColor.grayLight
    }
    
    func setupLoadingCell() {
        iconImageView.image = UIImage()
        self.label.hidden = true
        self.activity.hidden = false
        self.activity.startAnimating()
        self.imageView.image = UIImage()
    }

    func setupCellWithImageType(type: EditProductImageType) {
        switch type {
        case .Local(let image):
            setupCellWithImage(image)
        case .Remote(let file):
            setupCellWithUrl(file.fileURL)
        }
    }
    
    func setupCellWithImage(image: UIImage) {
        iconImageView.image = UIImage()
        self.label.hidden = true
        self.activity.hidden = true
        self.activity.stopAnimating()
        imageView.image = image
    }

    func setupCellWithUrl(url: NSURL?) {
        guard let url = url else { return }
        setupLoadingCell()
        imageView.lg_setImageWithURL(url, placeholderImage: nil, completion: { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            strongSelf.activity.stopAnimating()
            strongSelf.activity.hidden = true
            }
        )
    }

    func setupAddPictureCell() {
        self.label.hidden = false
        label.text = LGLocalizedString.sellPictureLabel.uppercase
        label.textColor = UIColor.redColor()
        self.activity.hidden = true
        iconImageView.image = UIImage(named: "ic_add_white")?.imageWithColor(UIColor.redColor())?.imageWithRenderingMode(.AlwaysOriginal)
        imageView.image = UIImage()
        self.backgroundColor = UIColor.whiteColor()
    }
}


// MARK: fancy highlight

extension SellProductCell {
    func highlight() {
        self.backgroundColor = UIColor.grayDark
        performSelector(#selector(resetBgColor), withObject: nil, afterDelay: 0.2)
    }

    dynamic private func resetBgColor() {
        self.backgroundColor = UIColor.black
    }
}
