import Foundation
import LGComponents

class ProductStatusView: UIView {

    private let statusLabel = UILabel()
    private let statusImageView = UIImageView(image: #imageLiteral(resourceName:"ic_lightning"))

    private var intrinsicWidth: CGFloat { return statusImageView.width + Metrics.bigMargin + statusLabel.width }

    private var imageToLabel: NSLayoutConstraint?
    private var labelToContainer: NSLayoutConstraint?

    override var intrinsicContentSize: CGSize { return CGSize(width: intrinsicWidth, height: 30) }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        statusLabel.textColor = UIColor.soldColor
        statusLabel.font = UIFont.productStatusSoldFont

        setupStatusImageView()
        setupStatusLabel()
    }

    private func setupStatusImageView() {
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusImageView)
        statusImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        statusImageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                 constant: Metrics.margin).isActive = true
        statusImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Metrics.veryShortMargin)
    }

    private func setupStatusLabel() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)
        statusLabel.text = R.Strings.bumpUpProductDetailFeaturedLabel
        statusLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.shortMargin).isActive = true
        statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.shortMargin).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                              constant: -Metrics.margin).isActive = true
        labelToContainer = statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                constant: Metrics.margin)
        imageToLabel = statusLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor,
                                                            constant: Metrics.margin)

        imageToLabel?.isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(height, width) / 2.0
    }

    func setFeaturedStatus(_ status: ListingViewModelStatus, featured isFeatured: Bool) {
        if isFeatured {
            backgroundColor = UIColor.white
            let featuredText = R.Strings.bumpUpProductDetailFeaturedLabel
            statusLabel.text = featuredText.capitalizedFirstLetterOnly
            statusLabel.textColor = UIColor.blackText
            statusImageView.isHidden = false
            imageToLabel?.isActive = true
            labelToContainer?.isActive = false
        } else {
            backgroundColor = status.bgColor
            statusLabel.text = status.string
            statusLabel.textColor = status.labelColor

            statusImageView.isHidden = true
            imageToLabel?.isActive = false
            labelToContainer?.isActive = true
        }
    }
}
