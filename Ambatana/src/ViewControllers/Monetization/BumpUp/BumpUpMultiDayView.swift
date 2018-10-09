import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

extension FeaturePurchaseType {
    var title: String? {
        switch self {
        case .bump:
            return R.Strings.bumpUpViewMultiDay1DayTitle
        case .threeDays:
            return R.Strings.bumpUpViewMultiDay3DaysTitle
        case .sevenDays:
            return R.Strings.bumpUpViewMultiDay7DaysTitle
        case .boost:
            return nil
        }
    }

    var subtitle: String? {
        switch self {
        case .bump:
            return R.Strings.bumpUpViewMultiDay1DaySubtitle
        case .threeDays:
            return R.Strings.bumpUpViewMultiDay3DaysSubtitle
        case .sevenDays:
            return R.Strings.bumpUpViewMultiDay7DaysSubtitle
        case .boost:
            return nil
        }
    }

    var tagText: String? {
        switch self {
        case .bump:
            return R.Strings.bumpUpViewMultiDay1DayTag
        case .threeDays:
            return R.Strings.bumpUpViewMultiDay3DaysTag
        case .sevenDays:
            return R.Strings.bumpUpViewMultiDay7DaysTag
        case .boost:
            return nil
        }
    }

    var backgroundImage: UIImage? {
        switch self {
        case .bump:
            return R.Asset.Monetization.featured1DayBackground.image
        case .threeDays:
            return R.Asset.Monetization.featured3DaysBackground.image
        case .sevenDays:
            return R.Asset.Monetization.featured7DaysBackground.image
        case .boost:
            return R.Asset.Monetization.featuredBackground.image
        }
    }
}

enum BumpUpMultiDayViewStatus {
    case collapsed
    case expanded

    var titleFontColor: UIColor {
        switch self {
        case .collapsed:
            return UIColor.grayRegular
        case .expanded:
            return UIColor.blackText
        }
    }

    var dayTagColor: UIColor {
        switch self {
        case .collapsed:    
            return UIColor.grayRegular
        case .expanded:
            return UIColor.terciaryColor
        }
    }
}

final class BumpUpMultiDayView: UIView {

    private enum Layout {
        static let collapsedHeight: CGFloat = 68
        static let daysTagWidth: CGFloat = 60
        static let daysTagHeight: CGFloat = 24
        static let featureButtonHeight: CGFloat = 50
    }

    fileprivate var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 21)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    fileprivate var daysTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 11)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        return label
    }()
    private var collapsibleViewsContainer: UIView = UIView()
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(size: 17)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    private var featureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()
    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    private var imageContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        return view
    }()
    private var listingImageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private var cellBottomImageContainer: UIView = UIView()
    private var cellBottomImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.Monetization.fakeCellBottom.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private var featuredRibbonImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.Monetization.redRibbon.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let featureButton: LetgoButton = {
        return LetgoButton(withStyle: .primary(fontSize: .big))
    }()

    lazy fileprivate var heightConstraint: NSLayoutConstraint = {
        return heightAnchor.constraint(equalToConstant: Layout.collapsedHeight)
    }()
    lazy fileprivate var collapsibleViewsContainerHeight: NSLayoutConstraint =  {
        return collapsibleViewsContainer.heightAnchor.constraint(equalToConstant: 0)
    }()
    lazy fileprivate var collapsibleViewsContainerBottom: NSLayoutConstraint =  {
        return collapsibleViewsContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.bigMargin)
    }()
    fileprivate var collapsibleViewsContainerConstraints: [NSLayoutConstraint] = []

    lazy fileprivate var titleTopConstraint: NSLayoutConstraint =  {
        return titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.bigMargin)
    }()
    lazy fileprivate var titleCenterYConstraint: NSLayoutConstraint = {
        return titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    }()
    lazy fileprivate var buttonHeightConstraint: NSLayoutConstraint = {
        return featureButton.heightAnchor.constraint(equalToConstant: Layout.featureButtonHeight)
    }()

    private let statusRelay = BehaviorRelay<BumpUpMultiDayViewStatus>(value: .collapsed)
    private var status: Driver<BumpUpMultiDayViewStatus> {
        return statusRelay.asDriver()
    }
    private var buttonAction: (()->Void)?

    private let disposeBag = DisposeBag()

    static func placeholderViewFor(featurePurchaseType: FeaturePurchaseType,
                                   status: BumpUpMultiDayViewStatus,
                                   listingImageUrl: URL?) -> BumpUpMultiDayView {
        return bumpUpMultiDayViewFor(featurePurchaseType: featurePurchaseType,
                                     priceString: nil,
                                     status: status, listingImageUrl: listingImageUrl,
                                     buttonAction: nil)
    }

    static func bumpUpMultiDayViewFor(featurePurchaseType: FeaturePurchaseType,
                                      priceString: String?,
                                      status: BumpUpMultiDayViewStatus,
                                      listingImageUrl: URL?,
                                      buttonAction: (()->Void)?) -> BumpUpMultiDayView {
        let view = BumpUpMultiDayView()
        view.setupConstraints()
        view.setupRx()
        view.setupUI(featurePurchaseType: featurePurchaseType,
                     priceString: priceString,
                     status: status,
                     listingImageUrl: listingImageUrl,
                     buttonAction: buttonAction)
        view.setAccessibilityIds()
        return view
    }

    func updateLayouts() {
        daysTagLabel.setRoundedCorners()
        renderListingCellShadows()
        imageContainer.setRoundedCorners(.allCorners, cornerRadius: LGUIKitConstants.mediumCornerRadius)
    }

    func collapse() {
        guard statusRelay.value == .expanded else { return }
        statusRelay.accept(.collapsed)
        heightConstraint.isActive = true
        collapsibleViewsContainerHeight.isActive = true
        titleTopConstraint.isActive = false
        titleCenterYConstraint.isActive = true
        collapsibleViewsContainerBottom.isActive = false
        collapsibleViewsContainer.isHidden = true
    }

    func expand() {
        guard statusRelay.value == .collapsed else { return }
        statusRelay.accept(.expanded)
        heightConstraint.isActive = false
        collapsibleViewsContainerHeight.isActive = false
        titleTopConstraint.isActive = true
        titleCenterYConstraint.isActive = false
        collapsibleViewsContainerBottom.isActive = true
        collapsibleViewsContainer.isHidden = false
    }

    func updateTextsForInfo(infoTitle: String, infoSubtitle: String) {
        titleLabel.text = infoTitle
        subtitleLabel.text = infoSubtitle
    }
    
    private func renderListingCellShadows() {
        shadowView.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.masksToBounds = false
    }

    private func setupConstraints() {
        addSubviewsForAutoLayout([titleLabel, daysTagLabel, collapsibleViewsContainer])
        collapsibleViewsContainer.addSubviewsForAutoLayout([subtitleLabel, featureImageView, featureButton])

        let constraints = [
            titleTopConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.bigMargin),
            daysTagLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Metrics.shortMargin),
            daysTagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.bigMargin),
            daysTagLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            daysTagLabel.widthAnchor.constraint(equalToConstant: Layout.daysTagWidth),
            daysTagLabel.heightAnchor.constraint(equalToConstant: Layout.daysTagHeight),
            collapsibleViewsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.shortMargin),
            collapsibleViewsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.bigMargin),
            collapsibleViewsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.bigMargin),
            collapsibleViewsContainerBottom
        ]
        NSLayoutConstraint.activate(constraints)

        collapsibleViewsContainerConstraints = [
            subtitleLabel.topAnchor.constraint(equalTo: collapsibleViewsContainer.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: collapsibleViewsContainer.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: collapsibleViewsContainer.trailingAnchor),
            featureImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            featureImageView.leadingAnchor.constraint(equalTo: collapsibleViewsContainer.leadingAnchor),
            featureImageView.trailingAnchor.constraint(equalTo: collapsibleViewsContainer.trailingAnchor),
            featureButton.topAnchor.constraint(equalTo: featureImageView.bottomAnchor, constant: Metrics.veryShortMargin),
            featureButton.bottomAnchor.constraint(equalTo: collapsibleViewsContainer.bottomAnchor),
            featureButton.leadingAnchor.constraint(equalTo: collapsibleViewsContainer.leadingAnchor),
            featureButton.trailingAnchor.constraint(equalTo: collapsibleViewsContainer.trailingAnchor),
            buttonHeightConstraint
        ]
        NSLayoutConstraint.activate(collapsibleViewsContainerConstraints)

        setupFakeListingCellConstraints()
    }

    private func setupFakeListingCellConstraints() {

        featureImageView.addSubviewsForAutoLayout([shadowView, imageContainer])
        let imageContainerConstraints: [NSLayoutConstraint] = [
            imageContainer.widthAnchor.constraint(equalTo: featureImageView.widthAnchor, multiplier: 0.33),
            imageContainer.widthAnchor.constraint(equalTo: imageContainer.heightAnchor, multiplier: 0.6),
            imageContainer.centerXAnchor.constraint(equalTo: featureImageView.centerXAnchor),
            imageContainer.centerYAnchor.constraint(equalTo: featureImageView.centerYAnchor),

            shadowView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            shadowView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            shadowView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor)
        ]
        NSLayoutConstraint.activate(imageContainerConstraints)

        imageContainer.addSubviewsForAutoLayout([listingImageView, cellBottomImageContainer, featuredRibbonImageView])

        let imagesConstraints = [
            featuredRibbonImageView.widthAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 0.25),
            featuredRibbonImageView.widthAnchor.constraint(equalTo: featuredRibbonImageView.heightAnchor),
            featuredRibbonImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            featuredRibbonImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            listingImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            listingImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            listingImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            listingImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor)
        ]
        NSLayoutConstraint.activate(imagesConstraints)

        cellBottomImageContainer.addSubviewForAutoLayout(cellBottomImageView)

        let cellBottomConstraints: [NSLayoutConstraint] = [
            cellBottomImageContainer.widthAnchor.constraint(equalTo: cellBottomImageContainer.heightAnchor, multiplier: 2),
            cellBottomImageContainer.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            cellBottomImageContainer.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            cellBottomImageContainer.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),

            cellBottomImageView.topAnchor.constraint(equalTo: cellBottomImageContainer.topAnchor),
            cellBottomImageView.leadingAnchor.constraint(equalTo: cellBottomImageContainer.leadingAnchor),
            cellBottomImageView.bottomAnchor.constraint(equalTo: cellBottomImageContainer.bottomAnchor),
            cellBottomImageView.trailingAnchor.constraint(equalTo: cellBottomImageContainer.trailingAnchor)
        ]
        NSLayoutConstraint.activate(cellBottomConstraints)
    }

    private func setupRx() {
        status.drive(rx.status).disposed(by: disposeBag)
    }

    private func setupUI(featurePurchaseType: FeaturePurchaseType,
                         priceString: String?,
                         status: BumpUpMultiDayViewStatus,
                         listingImageUrl: URL?,
                         buttonAction: (()->Void)?) {
        backgroundColor = UIColor.white
        if let imageUrl = listingImageUrl {
            listingImageView.lg_setImageWithURL(imageUrl,
                                                placeholderImage: nil,
                                                completion: { [weak self] (result, _) -> Void in
                                                    self?.imageContainer.isHidden = result.value == nil
            })
        } else {
            imageContainer.isHidden = true
        }

        titleLabel.text = featurePurchaseType.title
        subtitleLabel.text = featurePurchaseType.subtitle
        daysTagLabel.text = featurePurchaseType.tagText
        featureImageView.image = featurePurchaseType.backgroundImage

        self.buttonAction = buttonAction
        if let priceString = priceString {
            featureButton.setTitle(R.Strings.bumpUpViewPayButtonTitle(priceString), for: .normal)
            featureButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        } else {
            buttonHeightConstraint.constant = 0
            featureButton.isHidden = true
        }

        layer.cornerRadius = LGUIKitConstants.bigCornerRadius

        collapsibleViewsContainer.isHidden = status == .collapsed
        statusRelay.accept(status)
    }

    private func setAccessibilityIds() {
        titleLabel.set(accessibilityId: .multiDayBumpItemTitleLabel)
        daysTagLabel.set(accessibilityId: .multiDayBumpItemDaysTag)
        subtitleLabel.set(accessibilityId: .multiDayBumpItemSubtitleLabel)
        listingImageView.set(accessibilityId: .multiDayBumpItemListingImage)
        featureButton.set(accessibilityId: .multiDayBumpItemButton)
    }

    @objc private func buttonPressed() {
        buttonAction?()
    }
}

extension Reactive where Base: BumpUpMultiDayView {
    var status: Binder<BumpUpMultiDayViewStatus> {
        return Binder(base) { base, status in
            base.titleLabel.textColor = status.titleFontColor
            base.daysTagLabel.backgroundColor = status.dayTagColor

            base.heightConstraint.isActive = status == .collapsed
            base.collapsibleViewsContainerHeight.isActive = status == .collapsed
            base.titleTopConstraint.isActive = status != .collapsed
            base.titleCenterYConstraint.isActive = status == .collapsed
            base.collapsibleViewsContainerBottom.isActive = status != .collapsed
        }
    }
}
