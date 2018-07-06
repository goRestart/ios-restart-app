import Foundation
import LGComponents

final class ListingCardOnBoardingView: UIView {

    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let previousView = GestureView(image: R.Asset.IconsButtons.NewItemPage.nitTapGesture.image,
                                       text: R.Strings.productNitOnboardingPreviousPicture,
                                       alignment: .vertical)
    private let nextView = GestureView(image: R.Asset.IconsButtons.NewItemPage.nitTapGesture.image,
                                   text: R.Strings.productNitOnboardingNextPicture,
                                   alignment: .vertical)

    private let moreInfoView = GestureView(image: R.Asset.IconsButtons.NewItemPage.nitTapGesture.image,
                                           text: R.Strings.productMoreInfoOpenButton.lowercased().capitalizedFirstLetterOnly,
                                       alignment: .horizontal)

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    private func setupUI() {
        let movementsLayoutGuide = UILayoutGuide()

        addLayoutGuide(movementsLayoutGuide)
        addSubviewsForAutoLayout([visualEffectView, previousView, nextView, moreInfoView])
        NSLayoutConstraint.activate([
            movementsLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            movementsLayoutGuide.heightAnchor.constraint(equalTo: heightAnchor, constant: 0.6),

            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),

            previousView.bottomAnchor.constraint(equalTo: movementsLayoutGuide.centerYAnchor,
                                                 constant: -Metrics.margin),
            previousView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -Metrics.margin),
            previousView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Metrics.margin),

            nextView.widthAnchor.constraint(equalTo: previousView.widthAnchor),
            nextView.centerYAnchor.constraint(equalTo: previousView.centerYAnchor),
            nextView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: Metrics.margin),
            nextView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Metrics.margin),

            moreInfoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.veryBigMargin),
            moreInfoView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

private class GestureView: UIView {
    enum Alignment {
        case vertical
        case horizontal
    }
    private let imageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.setContentCompressionResistancePriority(.required, for: .vertical)
        return img
    }()
    private let actionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemBoldFont(size: 15)
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.numberOfLines = 2
        return lbl
    }()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    init(image: UIImage, text: String, alignment: Alignment) {
        super.init(frame: .zero)
        setupUIWith(image: image, text: text, alignment: alignment)
    }

    private func setupUIWith(image: UIImage, text: String, alignment: Alignment) {
        actionLabel.text = text
        imageView.image = image
        backgroundColor = .clear

        setupConstraintsWith(alignment: alignment)
    }

    private func setupConstraintsWith(alignment: Alignment) {
        addSubviewsForAutoLayout([imageView, actionLabel])
        switch alignment {
        case .vertical:
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

                actionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                actionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Metrics.margin),
                actionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                actionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        case .horizontal:
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                actionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Metrics.margin),
                actionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                actionLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        }
    }
}
