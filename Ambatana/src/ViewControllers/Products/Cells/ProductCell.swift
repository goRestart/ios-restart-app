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
    static let stripeIconWidth: CGFloat = 14
    
    @IBOutlet weak var shadowImage: UIImageView!
    @IBOutlet weak var cellContent: UIView!
    @IBOutlet weak var thumbnailBgColorView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var stripeImageView: UIImageView!

    @IBOutlet weak var stripeInfoView: UIView!
    @IBOutlet weak var stripeLabel: UILabel!
    @IBOutlet weak var stripeIcon: UIImageView!
    @IBOutlet weak var stripeIconWidth: NSLayoutConstraint!

    private var indexPath: IndexPath?
    
    var likeButtonEnabled: Bool = true
    var chatButtonEnabled: Bool = true

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }


    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        self.setAccessibilityIds()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }


    // MARK: - Public / internal methods

    func setBackgroundColor(id: String?) {
        thumbnailBgColorView.backgroundColor = UIColor.placeholderBackgroundColor(id)
    }
    
    func setImageUrl(_ imageUrl: URL) {
        thumbnailImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
            [weak self] (result, url) -> Void in
            if let (_, cached) = result.value, !cached {
                self?.thumbnailImageView.alpha = 0
                UIView.animate(withDuration: 0.4, animations: { self?.thumbnailImageView.alpha = 1 })
            }
        })
    }
    
    func setFreeStripe() {
        stripeIconWidth.constant = ProductCell.stripeIconWidth
        stripeImageView.image = UIImage(named: "stripe_white")
        stripeIcon.image = UIImage(named: "ic_heart")
        stripeLabel.text = LGLocalizedString.productFreePrice
        stripeImageView.isHidden = false
        stripeInfoView.isHidden = false
    }

    func setFeaturedStripe() {
        stripeIconWidth.constant = 0
        stripeImageView.image = UIImage(named: "stripe_white")
        stripeIcon.image = nil
        stripeLabel.text = LGLocalizedString.bumpUpProductCellFeaturedStripe
        stripeImageView.isHidden = false
        stripeInfoView.isHidden = false
    }


    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        cellContent.layer.cornerRadius = LGUIKitConstants.productCellCornerRadius
        let rotation = CGFloat(M_PI_4)
        stripeInfoView.transform = CGAffineTransform(rotationAngle: rotation)
        stripeLabel.textColor = UIColor.redText
        // HIDDEN for the moment while we experiment with 3 columns
        stripeInfoView.isHidden = true
        stripeImageView.isHidden = true
    }

    // Resets the UI to the initial state
    private func resetUI() {
        setBackgroundColor(id: nil)
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        stripeIcon.image = nil
        indexPath = nil
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .productCell
        thumbnailImageView.accessibilityId = .productCellThumbnailImageView
        stripeImageView.accessibilityId = .productCellStripeImageView
        stripeLabel.accessibilityId = .productCellStripeLabel
        stripeIcon.accessibilityId = .productCellStripeIcon
    }
}
