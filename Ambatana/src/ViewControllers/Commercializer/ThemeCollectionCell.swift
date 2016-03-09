//
//  ThemeCollectionCell.swift
//  LetGo
//
//  Created by Dídac on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ThemeCollectionCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var themeTitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var selectedShadowView: UIView!

    override var selected: Bool {
        didSet {
            setupUI()
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func setupWithTitle(title: String?, thumbnailURL: NSURL?, indexPath: NSIndexPath) {
        let tag = indexPath.hash

        themeTitleLabel.text = title ?? ""
        guard let thumbUrl = thumbnailURL else {
            thumbnailImageView.image = UIImage()
            return
        }

        thumbnailImageView.sd_setImageWithURL(thumbUrl) { [weak self] (image, error, cacheType, url)  in
            if error == nil && self?.tag == tag {
                self?.thumbnailImageView.image = image
            }
        }
    }

    func setupUI() {
        thumbnailImageView.contentMode = UIViewContentMode.ScaleAspectFit
        layer.borderColor = StyleHelper.primaryColor.CGColor
        layer.borderWidth = selected ? 2 : 0
        selectedShadowView.hidden = !selected
        iconImageView.image = UIImage(named: selected ? "ic_check_video" : "ic_play_thumb" )
    }
}
