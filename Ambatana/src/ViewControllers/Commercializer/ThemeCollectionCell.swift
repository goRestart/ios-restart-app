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
    @IBOutlet weak var disabledView: UIView!
    @IBOutlet weak var disabledLabel: UILabel!


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }


    // MARK: - Public methods

    func setupWithTitle(_ title: String?, thumbnailURL: URL?, playing: Bool, available: Bool, indexPath: IndexPath) {
        let tag = (indexPath as NSIndexPath).hash

        themeTitleLabel.text = title?.uppercase
        
//        layer.borderWidth = available ? (playing ? 2 : 0) : 0
        iconImageView.image = UIImage(named: playing ? "ic_check_video" : "ic_play_white" )
        selectedShadowView.isHidden = !playing
        disabledView.isHidden = available ? true : false

        if let thumbUrl = thumbnailURL {
            thumbnailImageView.lg_setImageWithURL(thumbUrl) { [weak self] (result, url)  in
                if let image = result.value?.image, self?.tag == tag {
                    self?.thumbnailImageView.image = image
                }
            }
        }
    }


    // MARK: - Private methods

    private func setupUI() {
        layer.borderColor = UIColor.primaryColor.cgColor
        thumbnailImageView.contentMode = UIViewContentMode.scaleAspectFit
        disabledLabel.text = LGLocalizedString.commercializerPromoteThemeAlreadyUsed
    }

    private func resetUI() {
        layer.borderWidth = 0
        themeTitleLabel.text = ""
        thumbnailImageView.image = nil
        iconImageView.image = nil
        disabledView.isHidden = true
    }
}
