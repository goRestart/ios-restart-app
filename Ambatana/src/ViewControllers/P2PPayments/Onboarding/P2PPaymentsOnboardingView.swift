import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsOnboardingView: UIView {
    private enum Layout {
        static let closeButtonTopMargin: CGFloat = 28
        static let closeButtonLeadingMargin: CGFloat = 8
        static let titleTopMargin: CGFloat = 28
        static let buttonHeight: CGFloat = 55
        static let buttonHorizontalMargin: CGFloat = 24
        static let buttonBottomMargin: CGFloat = 16
        static let stackViewMaxHeightDiff: CGFloat = 120
    }

    fileprivate let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.Asset.P2PPayments.close.image, for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lgBlack
        label.font = UIFont.systemBoldFont(size: 16)
        label.text = "How it works"
        return label
    }()

    private let traitsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 44, right: 0)
        return scrollView
    }()

    private let traitsStackView: UIStackView = {
        let firsTrait = TraitView(title: "Make your offer",
                                  subtitle: "You'll be charged and letgo will securely hold your funds in escrow until you confirm you've received the item",
                                  image: R.Asset.P2PPayments.onboardingStep1.image)
        let secondTrait = TraitView(title: "The seller accepts",
                                    subtitle: "You’ll get a notification that the seller has accepted your offer",
                                    image: R.Asset.P2PPayments.onboardingStep2.image)
        let thirdTrait = TraitView(title: "Meet in person and release the payment",
                                   subtitle: "When you have the item, release the payment to the seller",
                                   image: R.Asset.P2PPayments.onboardingStep3.image)
        let stackView = UIStackView(arrangedSubviews: [firsTrait, secondTrait, thirdTrait])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()

    fileprivate let makeAnOfferButton: LetgoButton = {
        let button = LetgoButton()
        button.setStyle(.primary(fontSize: .big))
        button.setTitle("Make an offer", for: .normal)
        return button
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = UIColor.white
        addSubviewsForAutoLayout([closeButton, titleLabel, traitsScrollView, makeAnOfferButton])
        traitsScrollView.addSubviewForAutoLayout(traitsStackView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.closeButtonLeadingMargin),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: Layout.closeButtonTopMargin),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Layout.titleTopMargin),
            traitsScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            traitsScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            traitsScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            traitsScrollView.bottomAnchor.constraint(equalTo: makeAnOfferButton.topAnchor),
            makeAnOfferButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.buttonHorizontalMargin),
            makeAnOfferButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.buttonHorizontalMargin),
            makeAnOfferButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.buttonBottomMargin),
            makeAnOfferButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            traitsStackView.leadingAnchor.constraint(equalTo: traitsScrollView.leadingAnchor),
            traitsStackView.trailingAnchor.constraint(equalTo: traitsScrollView.trailingAnchor),
            traitsStackView.topAnchor.constraint(equalTo: traitsScrollView.topAnchor),
            traitsStackView.bottomAnchor.constraint(equalTo: traitsScrollView.bottomAnchor),
            traitsStackView.widthAnchor.constraint(equalTo: widthAnchor),
            traitsStackView.heightAnchor.constraint(greaterThanOrEqualTo: traitsScrollView.heightAnchor, constant: -Layout.stackViewMaxHeightDiff)
        ])
    }
}

// MARK: - Trait view
private extension P2PPaymentsOnboardingView {
    private final class TraitView: UIView {
        private enum Layout {
            static let horizontalInset: CGFloat = 24
            static let imageToTextSpacing: CGFloat = 16
            static let titleToSubtitleSpacing: CGFloat = 8
            static let imageWidth: CGFloat = 44
        }

        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .center
            return imageView
        }()

        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemBoldFont(size: 20)
            label.textColor = .lgBlack
            label.numberOfLines = 0
            return label
        }()

        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.textColor = .grayDark
            label.numberOfLines = 0
            return label
        }()

        init(title: String, subtitle: String, image: UIImage?) {
            super.init(frame: .zero)
            setup(title: title, subtitle: subtitle, image: image)
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        private func setup(title: String, subtitle: String, image: UIImage?) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            imageView.image = image
            addSubviewsForAutoLayout([imageView, titleLabel, subtitleLabel])
            setupConstraints()
        }

        private func setupConstraints() {
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalInset),
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.widthAnchor.constraint(equalToConstant: Layout.imageWidth),
                titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Layout.imageToTextSpacing),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalInset),
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.titleToSubtitleSpacing),
                subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
    }
}

// MARK: - P2PPaymentsOnboardingView + Rx

extension Reactive where Base: P2PPaymentsOnboardingView {
    var closeButtonTap: ControlEvent<Void> {
        return base.closeButton.rx.tap
    }

    var makeAnOfferButtonTap: ControlEvent<Void> {
        return base.makeAnOfferButton.rx.tap
    }
}
