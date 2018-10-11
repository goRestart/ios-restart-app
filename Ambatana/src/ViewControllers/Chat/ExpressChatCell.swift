import UIKit
import LGComponents

private enum Layout {
    static let stackViewSpacing: CGFloat = 8
    static let cornerRadius = LGUIKitConstants.mediumCornerRadius
    static let defaultSpacing: CGFloat = 8
    static let tickBorderWidth: CGFloat = 0
    static let tickSize = CGSize(width: 20, height: 20)
}

final class ExpressChatCell: UICollectionViewCell, ReusableCell {
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let tickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let gradientView = UIView()
    private var shadowLayer: CALayer?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(size: 15)
        label.textColor = .white
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Layout.stackViewSpacing
        return stackView
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                select()
            } else {
                unSelect()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.af_cancelImageRequest()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGradientView()
    }
    
    private func setupUI() {
        isSelected = true
        cornerRadius = Layout.cornerRadius
        
        stackView.addArrangedSubviews([titleLabel, priceLabel])
        addSubviewsForAutoLayout([productImageView, tickImageView, gradientView, stackView])
        
        configureConstraints()
        setupAccessibilityIds()
    }
    
    private func configureConstraints() {
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let productImageViewConstraints = [
            productImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            productImageView.topAnchor.constraint(equalTo: topAnchor),
            productImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        productImageViewConstraints.activate()
        
        let tickImageViewConstraints = [
            tickImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.defaultSpacing),
            tickImageView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.defaultSpacing),
            tickImageView.widthAnchor.constraint(equalToConstant: Layout.tickSize.width),
            tickImageView.heightAnchor.constraint(equalToConstant: Layout.tickSize.height)
        ]
        tickImageViewConstraints.activate()
        
        let stackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.defaultSpacing),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.defaultSpacing),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.defaultSpacing)
        ]
        stackViewConstraints.activate()
        
        let gradientViewConstraints = [
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientView.topAnchor.constraint(equalTo: centerYAnchor)
        ]
        gradientViewConstraints.activate()
    }
    
    // MARK: - Configuration
    
    func configure(with title: String, price: String, imageUrl: URL?) {
        priceLabel.text = price
        titleLabel.text = title
        
        if let imageUrl = imageUrl {
            productImageView.af_setImage(withURL: imageUrl)
        }
    }
    
    // MARK: - Actions
    
    func select() {
        tickImageView.image = R.Asset.IconsButtons.checkboxSelectedRound.image
        tickImageView.layer.borderWidth = 0
    }
    
    func unSelect() {
        tickImageView.image = nil
        tickImageView.setRoundedCorners()
        
        tickImageView.layer.borderWidth = Layout.tickBorderWidth
        tickImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - Accesibility
    
    private func setupAccessibilityIds() {
        set(accessibilityId: .expressChatCell)
        titleLabel.set(accessibilityId: .expressChatCellListingTitle)
        priceLabel.set(accessibilityId: .expressChatCellListingPrice)
        tickImageView.set(accessibilityId: .expressChatCellTickSelected)
    }
    
    // MARK: - Gradient
 
    private func configureGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        shadowLayer = CAGradientLayer.gradientWithColor(.black, alphas:[0, 0.4], locations: [0, 1])
        
        if let shadowLayer = shadowLayer {
            shadowLayer.frame = gradientView.bounds
            gradientView.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}
