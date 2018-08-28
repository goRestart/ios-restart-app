import Foundation
import LGComponents

final class BumpUpBoostViewController: BaseViewController {

    struct BoostViewMetrics {
        static let bottomAnchorConstant: CGFloat = 20
        static let topAnchorConstant: CGFloat = 20
        static let redArrowSize: CGSize = CGSize(width: 15, height: 18)
        static let redArrowYOffset: CGFloat = 30
        static let smallYellowArrowYOffset: CGFloat = 40
        static let bigYellowArrowSize: CGSize = CGSize(width: 20, height: 25)
        static let smallYellowArrowSize: CGSize = CGSize(width: 12, height: 15)
    }

    static let timerUpdateInterval: TimeInterval = 1

    var titleLabelText: String {
        return R.Strings.bumpUpViewBoostTitleSendTop
    }

    func textForSubtitleLabelWith(time: TimeInterval?) -> NSAttributedString {
        guard let time = time, let timeString = Int(time).secondsToPrettyCountdownFormat(), !boostIsEnabled else {
            let string = R.Strings.bumpUpViewBoostSubtitleSendTop
            return NSAttributedString(string: string)
        }

        let timeAttributes: [NSAttributedStringKey: Any] = [.foregroundColor : UIColor.primaryColor,
                                                            .font : UIFont.systemBoldFont(size: 15)]

        let fullString = R.Strings.bumpUpViewBoostSubtitleNotReady(timeString)
        let fullAttributtedString = NSMutableAttributedString(string: fullString)

        let timeRange = NSString(string: fullString).range(of: timeString)
        fullAttributtedString.setAttributes(timeAttributes, range: timeRange)

        return fullAttributtedString
    }

    var boostIsEnabled: Bool {
        return timeIntervalLeft < (viewModel.maxCountdown - BumpUpBanner.boostBannerUIUpdateThreshold)
    }

    private var timerProgressView: BumpUpTimerBarView = BumpUpTimerBarView()

    private var closeButton: UIButton = UIButton()
    private var titleContainer: UIView = UIView()
    private var viewTitleIconView: UIImageView = UIImageView()
    private var viewTitleLabel: UILabel = UILabel()

    private var infoContainer: UIView = UIView()
    private var titleLabel: UILabel = UILabel()
    private var subtitleLabel: UILabel = UILabel()

    private var featuredBackgroundContainerView: UIView = UIView()
    private var featuredBgLeftColumnImageView: UIImageView = UIImageView()
    private var featuredBgRightColumnImageView: UIImageView = UIImageView()
    private var featuredBgBottomCellImageView: UIImageView = UIImageView()
    private var featuredBgRedArrow: UIImageView = UIImageView()
    private var featuredBgBigYellowArrow: UIImageView = UIImageView()
    private var featuredBgSmallYellowArrow: UIImageView = UIImageView()

    private var featuredRibbonImageView: UIImageView = UIImageView()
    private let shadowView: UIView = UIView()
    private var imageContainer: UIView = UIView()
    private var listingImageView: UIImageView = UIImageView()
    private var cellBottomContainer: UIView = UIView()
    private var cellBottomImageView: UIImageView = UIImageView()

    private var boostButton: LetgoButton = LetgoButton()

    private let featureFlags: FeatureFlaggeable
    private let viewModel: BumpUpPayViewModel

    private var timer: Timer = Timer()
    private var timeIntervalLeft: TimeInterval

    init(viewModel: BumpUpPayViewModel,
         featureFlags: FeatureFlaggeable,
         timeSinceLastBump: TimeInterval) {
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        self.timeIntervalLeft = viewModel.maxCountdown-timeSinceLastBump
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        startTimer()
        setAccessibilityIds()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        renderContainerCornerRadius()
        renderListingCellShadows()
        imageContainer.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }

    // MARK: - Actions

    @objc private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @objc private dynamic func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
        timer.invalidate()
    }

    @objc private dynamic func boostButtonPressed(_ sender: AnyObject) {
        viewModel.boostPressed()
    }

    // MARK: - Private methods

    private func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: BumpUpBoostViewController.timerUpdateInterval,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)

    }

    @objc private dynamic func updateTimer() {
        timeIntervalLeft = timeIntervalLeft-BumpUpBoostViewController.timerUpdateInterval
        timerProgressView.updateWith(timeLeft: timeIntervalLeft)

        if timeIntervalLeft == 0 {
            timer.invalidate()
            viewModel.timerReachedZero()
        } else if viewModel.maxCountdown - timeIntervalLeft <= BumpUpBanner.boostBannerUIUpdateThreshold {
            updateUIWith(time: BumpUpBanner.boostBannerUIUpdateThreshold - (viewModel.maxCountdown - timeIntervalLeft))
        } else {
            updateUIWith(time: nil)
        }
    }

    private func updateUIWith(time: TimeInterval?) {
        boostButton.isEnabled = time == nil
        titleLabel.text  = titleLabelText
        subtitleLabel.attributedText = textForSubtitleLabelWith(time: time)
    }

    private func setupUI() {
        setupTopView()
        setupInfoContainer()
        setupFakeCell()
        setupBoostButton()
        addSwipeDownGestureToView()
    }

    private func renderContainerCornerRadius() {
        infoContainer.cornerRadius = LGUIKitConstants.bigCornerRadius
        imageContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }

    private func renderListingCellShadows() {
        shadowView.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.masksToBounds = false
    }

    private func setupTopView() {
        timerProgressView.maxTime = viewModel.maxCountdown
        timerProgressView.updateWith(timeLeft: timeIntervalLeft)

        closeButton.setImage(R.Asset.Monetization.grayChevronDown.image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)

        viewTitleIconView.image = R.Asset.Monetization.icExtraBoost.image
        viewTitleIconView.contentMode = .scaleAspectFit
        viewTitleLabel.text = R.Strings.bumpUpBannerBoostText
        viewTitleLabel.textColor = UIColor.blackText
        viewTitleLabel.font = UIFont.systemBoldFont(size: 19)
        viewTitleLabel.minimumScaleFactor = 0.5
    }

    private func setupInfoContainer() {
        infoContainer.backgroundColor = UIColor.white

        titleLabel.text = titleLabelText
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.systemHeavyFont(size: 25)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.minimumScaleFactor = 0.3

        titleLabel.adjustsFontSizeToFitWidth = true

        subtitleLabel.attributedText = textForSubtitleLabelWith(time: viewModel.maxCountdown - timeIntervalLeft)
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = UIColor.grayText
        subtitleLabel.font = UIFont.systemFont(size: 17)
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0
        subtitleLabel.minimumScaleFactor = 0.3
        subtitleLabel.adjustsFontSizeToFitWidth = true

        featuredBackgroundContainerView.clipsToBounds = true

        featuredBgLeftColumnImageView.image = R.Asset.Monetization.boostBgLeftColumn.image
        featuredBgLeftColumnImageView.contentMode = .top

        featuredBgRightColumnImageView.image = R.Asset.Monetization.boostBgRightColumn.image
        featuredBgRightColumnImageView.contentMode = .top

        featuredBgBottomCellImageView.image = R.Asset.Monetization.boostBgBottomCell.image
        featuredBgBottomCellImageView.contentMode = .scaleAspectFill

        featuredBgRedArrow.image = R.Asset.Monetization.boostBgRedArrow.image
        featuredBgRedArrow.contentMode = .scaleAspectFit

        featuredBgBigYellowArrow.image = R.Asset.Monetization.boostBgYellowArrow.image
        featuredBgBigYellowArrow.contentMode = .scaleAspectFit

        featuredBgSmallYellowArrow.image = R.Asset.Monetization.boostBgYellowArrow.image
        featuredBgSmallYellowArrow.contentMode = .scaleAspectFit

    }

    private func setupFakeCell() {
        featuredRibbonImageView.image = R.Asset.Monetization.redRibbon.image
        featuredRibbonImageView.contentMode = .scaleAspectFit

        imageContainer.clipsToBounds = true
        imageContainer.layer.masksToBounds = false

        if let imageUrl = viewModel.listing.images.first?.fileURL {
            listingImageView.lg_setImageWithURL(imageUrl,
                                                placeholderImage: nil,
                                                completion: { [weak self] (result, _) -> Void in
                                                    self?.imageContainer.isHidden = result.value == nil
            })
        } else {
            imageContainer.isHidden = true
        }

        listingImageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        listingImageView.contentMode = .scaleAspectFill

        cellBottomImageView.image = R.Asset.Monetization.fakeCellBottom.image
        cellBottomImageView.contentMode = .scaleAspectFill
        shadowView.backgroundColor = UIColor.white
    }

    private func setupBoostButton() {
        boostButton.isEnabled = boostIsEnabled
        boostButton.setStyle(.primary(fontSize: .big))
        boostButton.setTitle(R.Strings.bumpUpViewBoostPayButtonTitle(viewModel.price), for: .normal)
        boostButton.titleLabel?.numberOfLines = 2
        boostButton.titleLabel?.adjustsFontSizeToFitWidth = true
        boostButton.titleLabel?.minimumScaleFactor = 0.5
        boostButton.addTarget(self, action: #selector(boostButtonPressed), for: .touchUpInside)
    }

    private func addSwipeDownGestureToView() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    private func setupConstraints() {
        let mainSubviews: [UIView] = [timerProgressView, closeButton, titleContainer, infoContainer]
        view.addSubviewsForAutoLayout(mainSubviews)

        if #available(iOS 11, *) {
            timerProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            infoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                  constant: -BoostViewMetrics.bottomAnchorConstant).isActive = true
        } else {
            timerProgressView.topAnchor.constraint(equalTo: view.topAnchor,
                                                   constant: BoostViewMetrics.topAnchorConstant).isActive = true
            infoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                  constant: -BoostViewMetrics.bottomAnchorConstant).isActive = true
        }
        timerProgressView.layout(with: view).left().right()
        timerProgressView.layout().height(BumpUpTimerBarViewMetrics.height)
        
        closeButton.layout().width(Metrics.closeButtonWidth).height(Metrics.closeButtonHeight)
        closeButton.layout(with: view).left()
        closeButton.layout(with: timerProgressView).below()
        closeButton.layout(with: titleContainer)
            .right(to: .left, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
            .centerY()
            .proportionalHeight()
        titleContainer.layout(with: view).centerX().right(by: -Metrics.margin, relatedBy: .lessThanOrEqual)

        infoContainer.layout(with: closeButton).below(by: Metrics.margin)
        infoContainer.layout(with: view).left(by: Metrics.shortMargin).right(by: -Metrics.shortMargin)

        setupTitleViewConstraints()

        setupInfoContainterConstraints()
    }

    private func setupTitleViewConstraints() {
        let titleContainerSubviews: [UIView] = [viewTitleIconView, viewTitleLabel]
        titleContainer.addSubviewsForAutoLayout(titleContainerSubviews)

        viewTitleIconView.layout().width(Metrics.bigMargin).height(Metrics.bigMargin)
        viewTitleIconView.layout(with: titleContainer).left()
        viewTitleIconView.layout(with: viewTitleLabel)
            .right(to: .left, by: -Metrics.veryShortMargin, relatedBy: .lessThanOrEqual)
            .centerY()
        viewTitleLabel.layout(with: titleContainer).right().top(by: Metrics.margin).bottom()
    }

    private func setupInfoContainterConstraints() {
        let infoContainerSubviews: [UIView] = [titleLabel,
                                               subtitleLabel,
                                               featuredBackgroundContainerView,
                                               boostButton]
        infoContainer.addSubviewsForAutoLayout(infoContainerSubviews)

        titleLabel.layout(with: infoContainer)
            .top(by: Metrics.shortMargin)
            .fillHorizontal(by: Metrics.bigMargin)

        titleLabel.layout(with: subtitleLabel).above(by: -Metrics.veryShortMargin)

        subtitleLabel.layout(with: infoContainer)
            .fillHorizontal(by: Metrics.bigMargin)

        subtitleLabel.layout(with: featuredBackgroundContainerView).above(by: -Metrics.margin)

        featuredBackgroundContainerView.layout(with: infoContainer)
            .fillHorizontal(by: Metrics.bigMargin)
        
        featuredBackgroundContainerView.layout(with: boostButton).above(by: -Metrics.shortMargin)

        boostButton.layout().height(Metrics.buttonHeight)
        boostButton.layout(with: infoContainer)
            .fillHorizontal(by: Metrics.bigMargin)
            .bottom(by: -Metrics.margin)

        setupBoostImagesConstraints()
        setupFakeListingCellConstraints()
    }

    private func setupBoostImagesConstraints() {
        let bgSubviews: [UIView] = [featuredBgLeftColumnImageView,
                                    featuredBgRightColumnImageView,
                                    featuredBgBottomCellImageView,
                                    shadowView,
                                    imageContainer,
                                    featuredBgRedArrow,
                                    featuredBgBigYellowArrow,
                                    featuredBgSmallYellowArrow]
        featuredBackgroundContainerView.addSubviewsForAutoLayout(bgSubviews)

        imageContainer.layout(with: featuredBackgroundContainerView).proportionalWidth(multiplier: 0.33)
        imageContainer.layout().widthProportionalToHeight(multiplier: 0.6)
        imageContainer.layout(with: featuredBackgroundContainerView)
            .top(by: Metrics.veryShortMargin)
            .centerX()
            .bottom(to: .bottom, by: 0, relatedBy: .lessThanOrEqual)

        featuredBgBottomCellImageView.layout(with: imageContainer)
            .proportionalWidth()
            .below(by: Metrics.bigMargin)
            .centerX()

        featuredBgLeftColumnImageView.layout(with: imageContainer)
            .proportionalWidth(multiplier: 0.9)
        featuredBgLeftColumnImageView.layout(with: featuredBackgroundContainerView)
            .top()
            .left(to: .left, by: 0, priority: .defaultLow)
        featuredBgLeftColumnImageView.layout(with: imageContainer).right(to: .left, by: -Metrics.shortMargin)

        featuredBgRightColumnImageView.layout(with: imageContainer).proportionalWidth(multiplier: 0.9)
        featuredBgRightColumnImageView.layout(with: featuredBackgroundContainerView)
            .top()
            .right(to: .right, by: 0, priority: .defaultLow)
        featuredBgRightColumnImageView.layout(with: imageContainer).left(to: .right, by: Metrics.shortMargin)

        setupArrowConstraints()
    }

    private func setupFakeListingCellConstraints() {
        let imageContainerSubviews: [UIView] = [listingImageView, cellBottomContainer, featuredRibbonImageView]
        imageContainer.addSubviewsForAutoLayout(imageContainerSubviews)

        featuredRibbonImageView.layout(with: imageContainer).top().right().proportionalWidth(multiplier: 0.25)
        featuredRibbonImageView.layout().widthProportionalToHeight()

        listingImageView.layout(with: imageContainer).fill()

        cellBottomContainer.layout().widthProportionalToHeight(multiplier: 2)
        cellBottomContainer.layout(with: imageContainer).left().right().bottom()

        cellBottomContainer.addSubviewForAutoLayout(cellBottomImageView)
        cellBottomImageView.layout(with: cellBottomContainer).fill()

        shadowView.layout(with: imageContainer).center().fill()
    }

    private func setupArrowConstraints() {
        featuredBgRedArrow.layout()
            .width(BoostViewMetrics.redArrowSize.width)
            .height(BoostViewMetrics.redArrowSize.height)
        featuredBgBigYellowArrow.layout()
            .width(BoostViewMetrics.bigYellowArrowSize.width)
            .height(BoostViewMetrics.bigYellowArrowSize.height)
        featuredBgSmallYellowArrow.layout()
            .width(BoostViewMetrics.smallYellowArrowSize.width)
            .height(BoostViewMetrics.smallYellowArrowSize.height)

        featuredBgRedArrow.layout(with: imageContainer)
            .centerY(by: -BoostViewMetrics.redArrowYOffset)
            .right(to: .left, by: -Metrics.bigMargin)
        featuredBgBigYellowArrow.layout(with: imageContainer).top(by: -Metrics.veryShortMargin).left(to: .right, by: Metrics.veryShortMargin)
        featuredBgSmallYellowArrow.layout(with: imageContainer)
            .centerY(by: BoostViewMetrics.smallYellowArrowYOffset)
            .left(to: .right, by: Metrics.margin)
    }

    private func setAccessibilityIds() {
        timerProgressView.set(accessibilityId: .boostViewTimer)
        closeButton.set(accessibilityId: .boostViewCloseButton)
        listingImageView.set(accessibilityId: .boostViewImage)
        titleLabel.set(accessibilityId: .boostViewTitleLabel)
        subtitleLabel.set(accessibilityId: .boostViewSubtitleLabel)
        boostButton.set(accessibilityId: .boostViewButton)
    }
}
