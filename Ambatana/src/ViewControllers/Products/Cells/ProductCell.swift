//
//  ProductCell.swift
//  LetGo
//
//  Created by AHL on 13/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import pop

protocol ProductCellDelegate: class {
    func onProductCellDidChat(cell: ProductCell, indexPath: NSIndexPath)
    func onProductCellDidShare(cell: ProductCell, indexPath: NSIndexPath)
    func onProductCellDidLike(cell: ProductCell, indexPath: NSIndexPath)
}

class ProductCell: UICollectionViewCell, ReusableCell {

    private static let buttonsContainerShownHeight: CGFloat = 34
    
    @IBOutlet weak var shadowImage: UIImageView!
    @IBOutlet weak var cellContent: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var thumbnailBgColorView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var priceGradientView: UIView!

    @IBOutlet weak var buttonsContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!

    @IBOutlet weak var stripeImageView: UIImageView!
    @IBOutlet weak var stripeLabel: UILabel!

    private var indexPath: NSIndexPath?
    private weak var delegate: ProductCellDelegate?

    
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

    
    // MARK: - Static methods

    static func reusableID() -> String {
        return "ProductCell"
    }


    // MARK: - Public / internal methods

    func setupActions(show: Bool, delegate: ProductCellDelegate?, indexPath: NSIndexPath?) {
        self.indexPath = indexPath
        self.delegate = delegate
        if let _ = delegate, let _ = indexPath where show {
            self.buttonsContainerHeight.constant = ProductCell.buttonsContainerShownHeight
        } else {
            self.buttonsContainerHeight.constant = 0
        }
    }

    func setImageUrl(imageUrl: NSURL) {
        thumbnailImageView.sd_setImageWithURL(imageUrl, placeholderImage: nil, completed: {
            [weak self] (image, error, cacheType, url) -> Void in
            if cacheType == .None {
                let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                alphaAnim.fromValue = 0
                alphaAnim.toValue = 1
                self?.thumbnailImageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
            }
            })
    }

    func setCellWidth(width: CGFloat) {
        if let sublayers = priceGradientView.layer.sublayers {
            let gradientBounds = CGRect(x: 0, y: 0, width: width, height: priceGradientView.height)
            for sublayer in sublayers {
                sublayer.frame = gradientBounds
            }
        }
    }


    // MARK: - Actions

    @IBAction func onDirectChatBtn(sender: AnyObject) {
        guard let indexPath = indexPath else { return }
        delegate?.onProductCellDidChat(self, indexPath: indexPath)
    }

    @IBAction func onDirectShareBtn(sender: AnyObject) {
        guard let indexPath = indexPath else { return }
        delegate?.onProductCellDidShare(self, indexPath: indexPath)
    }
    
    @IBAction func onDirectLikeBtn(sender: AnyObject) {
        guard let indexPath = indexPath else { return }
        delegate?.onProductCellDidLike(self, indexPath: indexPath)
    }


    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        cellContent.layer.cornerRadius = StyleHelper.defaultCornerRadius
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.0,0.4],
            locations: [0.0,1.0])
        shadowLayer.frame = priceGradientView.bounds
        priceGradientView.layer.addSublayer(shadowLayer)
        let rotation = CGFloat(M_PI_4)
        stripeLabel.transform = CGAffineTransformMakeRotation(rotation)
    }

    // Resets the UI to the initial state
    private func resetUI() {
        priceLabel.text = ""
        thumbnailBgColorView.backgroundColor = StyleHelper.productCellBgColor
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        indexPath = nil
        delegate = nil
    }
}
