//
//  SellProductCell.swift
//  LetGo
//
//  Created by Dídac on 27/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SellProductCell: UICollectionViewCell, ReusableCell {

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
        self.label.isHidden = true
        self.activity.isHidden = true
        self.activity.stopAnimating()
        self.imageView.image = UIImage()
        self.backgroundColor = UIColor.grayLight
    }
    
    func setupLoadingCell() {
        iconImageView.image = UIImage()
        self.label.isHidden = true
        self.activity.isHidden = false
        self.activity.startAnimating()
        self.imageView.image = UIImage()
    }

    func setupCellWithImageType(_ type: EditProductImageType) {
        switch type {
        case .local(let image):
            setupCellWithImage(image)
        case .remote(let file):
            setupCellWithUrl(file.fileURL)
        }
    }
    
    func setupCellWithImage(_ image: UIImage) {
        iconImageView.image = UIImage()
        self.label.isHidden = true
        self.activity.isHidden = true
        self.activity.stopAnimating()
        imageView.image = image
    }

    func setupCellWithUrl(_ url: URL?) {
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
        self.label.isHidden = false
        label.text = LGLocalizedString.sellPictureLabel.uppercase
        label.textColor = UIColor.red
        self.activity.isHidden = true
        iconImageView.image = UIImage(named: "ic_add_white")?.imageWithColor(UIColor.red)?.withRenderingMode(.alwaysOriginal)
        imageView.image = UIImage()
        self.backgroundColor = UIColor.white
    }
}


// MARK: fancy highlight

extension SellProductCell {
    func highlight() {
        self.backgroundColor = UIColor.secondaryColorHighlighted
        perform(#selector(resetBgColor), with: nil, afterDelay: 0.2)
    }

    dynamic private func resetBgColor() {
        self.backgroundColor = UIColor.white
    }
}
