//
//  ProductCell.swift
//  LetGo
//
//  Created by AHL on 13/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell, ReusableCell {

    static let reusableID = "ProductCell"
    static let buttonsContainerShownHeight: CGFloat = 34
    
    @IBOutlet weak var shadowImage: UIImageView!
    @IBOutlet weak var cellContent: UIView!
    @IBOutlet weak var thumbnailBgColorView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var stripeImageView: UIImageView!

    @IBOutlet weak var stripeInfoView: UIView!
    @IBOutlet weak var stripeLabel: UILabel!
    @IBOutlet weak var stripeIcon: UIImageView!
    @IBOutlet weak var stripeIconWidth: NSLayoutConstraint!

    private var indexPath: NSIndexPath?
    
    var likeButtonEnabled: Bool = true
    var chatButtonEnabled: Bool = true

    override var highlighted: Bool {
        didSet {
            alpha = highlighted ? 0.8 : 1.0
        }
    }


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

    func setImageUrl(imageUrl: NSURL) {
        thumbnailImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
            [weak self] (result, url) -> Void in
            if let (_, cached) = result.value where !cached {
                self?.thumbnailImageView.alpha = 0
                UIView.animateWithDuration(0.4, animations: { self?.thumbnailImageView.alpha = 1 })
            }
        })
    }
    
    func setFreeStripe() {
            stripeImageView.image = UIImage(named: "stripe_white")
            stripeIcon.image = UIImage(named: "ic_heart")
            stripeLabel.text = LGLocalizedString.productFreePrice
            stripeImageView.hidden = false
            stripeInfoView.hidden = false
            stripeImageView.hidden = false
    }


    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        cellContent.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        let rotation = CGFloat(M_PI_4)
        stripeInfoView.transform = CGAffineTransformMakeRotation(rotation)
        stripeLabel.textColor = UIColor.redText
        // HIDDEN for the moment while we experiment with 3 columns
        stripeInfoView.hidden = true
        stripeImageView.hidden = true
    }

    // Resets the UI to the initial state
    private func resetUI() {
        thumbnailBgColorView.backgroundColor = UIColor.placeholderBackgroundColor()
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        stripeIcon.image = nil
        indexPath = nil
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .ProductCell
        thumbnailImageView.accessibilityId = .ProductCellThumbnailImageView
        stripeImageView.accessibilityId = .ProductCellStripeImageView
        stripeLabel.accessibilityId = .ProductCellStripeLabel
        stripeIcon.accessibilityId = .ProductCellStripeIcon
    }
}
