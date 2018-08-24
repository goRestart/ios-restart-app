import UIKit
import LGComponents

struct LGRibbonConfiguration {
    let title: String
    let icon: UIImage?
    let titleColor: UIColor
}

final class LGRibbonView: UIView {

    private enum Layout {
        static let imageViewDimension: CGFloat = 70
        static let imageViewEdgeOffset: CGFloat = 2
        static let ribbonWidth: CGFloat = 50
        static let ribbonHeight: CGFloat = 24
        static let ribbonLeadingOffset: CGFloat = 20
        static let ribbonCenterYOffset: CGFloat = -8
    }

    //  MARK: - Subviews

    private let stripeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 12)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .lgBlack
        return label
    }()

    private let stripeIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = R.Asset.IconsButtons.icHeart.image
        return iv
    }()

    private let ribbonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        stack.distribution = .fillProportionally
        stack.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
        return stack
    }()

    private let stripeImageView = UIImageView(image: R.Asset.BackgroundsAndImages.stripeWhite.image)

    init(configuration: LGRibbonConfiguration? = nil) {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupRibbon(configuration: configuration)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func clear() {
        stripeLabel.text = nil
        stripeIcon.image = nil
    }

    func setupRibbon(configuration: LGRibbonConfiguration?) {
        stripeIcon.isHidden = configuration?.icon == nil
        stripeIcon.image = configuration?.icon
        stripeLabel.textAlignment = (configuration?.icon == nil) ? .center : .left
        stripeLabel.text = configuration?.title
        stripeLabel.textColor = configuration?.titleColor
    }


    //  MARK: - Private methods

    private func setupSubviews() {
        clipsToBounds = true
        ribbonStack.addArrangedSubviews([stripeIcon, stripeLabel])
        addSubviewsForAutoLayout([stripeImageView, ribbonStack])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stripeImageView.widthAnchor.constraint(equalToConstant: Layout.imageViewDimension),
            stripeImageView.heightAnchor.constraint(equalToConstant: Layout.imageViewDimension),
            stripeImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.imageViewEdgeOffset),
            stripeImageView.topAnchor.constraint(equalTo: topAnchor, constant: -Layout.imageViewEdgeOffset),

            ribbonStack.widthAnchor.constraint(equalToConstant: Layout.ribbonWidth),
            ribbonStack.heightAnchor.constraint(equalToConstant: Layout.ribbonHeight),
            ribbonStack.leadingAnchor.constraint(equalTo: stripeImageView.leadingAnchor,
                                                 constant: Layout.ribbonLeadingOffset),
            ribbonStack.centerYAnchor.constraint(equalTo: stripeImageView.centerYAnchor,
                                                 constant: Layout.ribbonCenterYOffset),
            ])
    }
}
