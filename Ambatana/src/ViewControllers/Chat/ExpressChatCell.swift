import UIKit
import LGComponents

class ExpressChatCell: UICollectionViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    var shadowLayer: CALayer?


    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientView()
    }

    override var isSelected: Bool {
        didSet {
            selectedImageView.image = isSelected ? R.Asset.IconsButtons.checkboxSelectedRound.image : nil
            selectedImageView.layer.borderWidth = isSelected ? 0 : 2
        }
    }

    func configureCellWithTitle(_ title: String, imageUrl: URL?, price: String, cornerRadius: CGFloat) {
        selectedImageView.layer.borderColor = UIColor.white.cgColor
        selectedImageView.setRoundedCorners()
        priceLabel.text = price
        titleLabel.text = title

        self.cornerRadius = cornerRadius
        productImageView.image = R.Asset.IconsButtons.productPlaceholder.image
        if let imageURL = imageUrl {
            productImageView.lg_setImageWithURL(imageURL) { [weak self] (result, _ ) in
                if let image = result.value?.image {
                    self?.productImageView.image = image
                }
            }
        }
        
        setupAccessibilityIds()
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func setupGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        shadowLayer = CAGradientLayer.gradientWithColor(UIColor.black, alphas:[0, 0.4], locations: [0, 1])
        if let shadowLayer = shadowLayer {
            shadowLayer.frame = gradientView.bounds
            gradientView.layer.insertSublayer(shadowLayer, at: 0)
        }
    }

    func setupAccessibilityIds() {
        self.set(accessibilityId: .expressChatCell)
        self.titleLabel.set(accessibilityId: .expressChatCellListingTitle)
        self.priceLabel.set(accessibilityId: .expressChatCellListingPrice)
        self.selectedImageView.set(accessibilityId: .expressChatCellTickSelected)
    }
}
