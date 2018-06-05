import Foundation
import RxSwift
import LGComponents

protocol ListingDeckOnBoardingViewRxType: class {
    var rxConfirmButton: Reactive<LetgoButton> { get }
}

final class ListingDeckOnBoardingView: UIView, ListingDeckOnBoardingViewRxType {
    var rxConfirmButton: Reactive<LetgoButton> { return confirmButton.rx }
    
    private struct Layout {
        struct FontSize {
            static let title: Int = 23
        }
        struct Height {
            static let containerView: CGFloat = 0.6
            static let imageView: CGFloat = 0.45
            static let confirmButton: CGFloat = 44.0
        }
        struct Width {
            static let containerView: CGFloat = 0.7
        }
        struct CornerRadius {
            static let confirmButton: CGFloat = Layout.Height.confirmButton / 2.0
            static let containerView: CGFloat = 8.0
        }
    }
    private let containerView = UIView()
    private let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let imageView = UIImageView(image: R.Asset.IconsButtons.NewItemPage.nitOnboarding.image)
    private let titleLabel = UILabel()
    private let underline = UIView()
    private let confirmButton = LetgoButton(withStyle: .primary(fontSize: .big))

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setVisualEffectAlpha(_ alpha: CGFloat) {
        visualEffect.alpha = alpha
    }

    func compressContentView() {
        containerView.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
    }

    func expandContainerView() {
        containerView.transform = CGAffineTransform.identity
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        setupBlur()
        setupContainerView()
        setupImageView()
        setupTitle()
        setupUnderline()
        setupConfirmButton()
    }

    private func setupBlur() {
        addSubviewForAutoLayout(visualEffect)

        visualEffect.alpha = 0.5
        visualEffect.backgroundColor = UIColor.black

        let constraints = [
            visualEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffect.topAnchor.constraint(equalTo: topAnchor),
            visualEffect.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupContainerView() {
        addSubviewForAutoLayout(containerView)

        let constraints = [
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Metrics.veryBigMargin),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Metrics.veryBigMargin),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Metrics.veryBigMargin),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Metrics.veryBigMargin)
        ]
        NSLayoutConstraint.activate(constraints)

        containerView.setContentHuggingPriority(.required, for: .vertical)
        containerView.setContentHuggingPriority(.required, for: .horizontal)

        containerView.backgroundColor = UIColor.viewControllerBackground
    }

    private func setupImageView() {
        containerView.addSubviewForAutoLayout(imageView)
        imageView.contentMode = .scaleAspectFit
        let imageHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor,
                                                            multiplier: Layout.Height.imageView)
        imageHeight.priority = .required - 1
        let constraints = [
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.margin),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Metrics.veryBigMargin),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.margin),
            imageHeight
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupTitle() {
        containerView.addSubviewForAutoLayout(titleLabel)
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.veryBigMargin),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Metrics.veryBigMargin),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.veryBigMargin)
        ]
        NSLayoutConstraint.activate(constraints)
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemBoldFont(size: Layout.FontSize.title)
        titleLabel.textAlignment = .left
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.text = R.Strings.productDetailSwipeToSeeRelated
    }

    private func setupUnderline() {
        containerView.addSubviewForAutoLayout(underline)
        let constraints = [
            underline.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            underline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.veryBigMargin),
            underline.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            underline.heightAnchor.constraint(equalToConstant: LGUIKitConstants.onePixelSize)
        ]
        NSLayoutConstraint.activate(constraints)
        underline.backgroundColor = UIColor.lightGray
    }

    private func setupConfirmButton() {
        containerView.addSubviewForAutoLayout(confirmButton)
        let constraints = [
            confirmButton.heightAnchor.constraint(equalToConstant: Layout.Height.confirmButton),
            confirmButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            confirmButton.topAnchor.constraint(equalTo: underline.bottomAnchor, constant: Metrics.veryBigMargin),
            confirmButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Metrics.veryBigMargin)
        ]
        NSLayoutConstraint.activate(constraints)
        confirmButton.setTitle(R.Strings.commonOk, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.setRoundedCorners(.allCorners, cornerRadius: Layout.CornerRadius.containerView)
        confirmButton.layer.cornerRadius = Layout.CornerRadius.confirmButton
    }
}
