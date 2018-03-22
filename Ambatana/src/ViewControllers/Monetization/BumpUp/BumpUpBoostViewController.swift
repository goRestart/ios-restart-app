//
//  BumpUpBoostViewController.swift
//  LetGo
//
//  Created by Dídac on 21/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class BumpUpBoostViewController: BaseViewController {

    struct BoostViewMetrics {
        static let bottomAnchorConstant: CGFloat = 40
        static let redArrowSize: CGSize = CGSize(width: 15, height: 18)
        static let redArrowYOffset: CGFloat = 30
        static let smallYellowArrowYOffset: CGFloat = 40
        static let bigYellowArrowSize: CGSize = CGSize(width: 20, height: 25)
        static let smallYellowArrowSize: CGSize = CGSize(width: 12, height: 15)
    }

    static let timerUpdateInterval: TimeInterval = 1

    var titleLabelText: String {
        switch featureFlags.bumpUpBoost {
        case .control, .baseline, .sendTop1hour, .sendTop5Mins:
            return LGLocalizedString.bumpUpViewBoostTitleSendTop
        case .boostListing1hour:
            return LGLocalizedString.bumpUpViewBoostTitleBoostListing
        case .cheaperBoost5Mins:
            return LGLocalizedString.bumpUpViewBoostTitleCheaperBoost
        }
    }

    var subtitleLabelText: String {
        switch featureFlags.bumpUpBoost {
        case .control, .baseline, .sendTop1hour, .sendTop5Mins:
            return LGLocalizedString.bumpUpViewBoostSubtitleSendTop
        case .boostListing1hour:
            return LGLocalizedString.bumpUpViewBoostSubtitleBoostListing
        case .cheaperBoost5Mins:
            return LGLocalizedString.bumpUpViewBoostSubtitleCheaper
        }
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

    private let maxCountdown: TimeInterval
    private var timer: Timer = Timer()
    private var timeIntervalLeft: TimeInterval

    init(viewModel: BumpUpPayViewModel,
         featureFlags: FeatureFlaggeable,
         timeSinceLastBump: TimeInterval,
         maxCountdown: TimeInterval) {
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        self.maxCountdown = maxCountdown
        self.timeIntervalLeft = maxCountdown-timeSinceLastBump
        super.init(viewModel: viewModel, nibName: nil)
        modalPresentationStyle = .overCurrentContext
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
        }
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
        timerProgressView.maxTime = maxCountdown
        timerProgressView.updateWith(timeLeft: timeIntervalLeft)

        closeButton.setImage(#imageLiteral(resourceName: "gray_chevron_down"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)

        viewTitleIconView.image = #imageLiteral(resourceName: "ic_extra_boost")
        viewTitleIconView.contentMode = .scaleAspectFit
        viewTitleLabel.text = LGLocalizedString.bumpUpBannerBoostText
        viewTitleLabel.textColor = UIColor.blackText
        viewTitleLabel.font = UIFont.systemSemiBoldFont(size: 17)
        viewTitleLabel.minimumScaleFactor = 0.5
    }

    private func setupInfoContainer() {
        infoContainer.backgroundColor = UIColor.white

        titleLabel.text = titleLabelText
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.systemBoldFont(size: 25)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.minimumScaleFactor = 0.3

        titleLabel.adjustsFontSizeToFitWidth = true // 🦄

        subtitleLabel.text = subtitleLabelText
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = UIColor.grayText
        subtitleLabel.font = UIFont.systemFont(size: 17)
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0
        subtitleLabel.minimumScaleFactor = 0.3
        subtitleLabel.adjustsFontSizeToFitWidth = true

        featuredBackgroundContainerView.clipsToBounds = true

        featuredBgLeftColumnImageView.image = #imageLiteral(resourceName: "boost_bg_left_column")
        featuredBgLeftColumnImageView.contentMode = .top //.scaleAspectFit

        featuredBgRightColumnImageView.image = #imageLiteral(resourceName: "boost_bg_right_column")
        featuredBgRightColumnImageView.contentMode = .top //.scaleAspectFit

        featuredBgBottomCellImageView.image = #imageLiteral(resourceName: "boost_bg_bottom_cell")
        featuredBgBottomCellImageView.contentMode = .scaleAspectFill

        featuredBgRedArrow.image = #imageLiteral(resourceName: "boost_bg_red_arrow")
        featuredBgRedArrow.contentMode = .scaleAspectFit

        featuredBgBigYellowArrow.image = #imageLiteral(resourceName: "boost_bg_yellow_arrow")
        featuredBgBigYellowArrow.contentMode = .scaleAspectFit

        featuredBgSmallYellowArrow.image = #imageLiteral(resourceName: "boost_bg_yellow_arrow")
        featuredBgSmallYellowArrow.contentMode = .scaleAspectFit

    }

    private func setupFakeCell() {
        featuredRibbonImageView.image = #imageLiteral(resourceName: "red_ribbon")
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

        cellBottomImageView.image = #imageLiteral(resourceName: "fake_cell_bottom")
        cellBottomImageView.contentMode = .scaleAspectFill
        shadowView.backgroundColor = UIColor.white
    }

    private func setupBoostButton() {
        boostButton.setStyle(.primary(fontSize: .big))
        boostButton.setTitle(LGLocalizedString.bumpUpViewBoostPayButtonTitle(viewModel.price), for: .normal)
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
        view.addSubviews(mainSubviews)
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: mainSubviews)

        if #available(iOS 11, *) {
            timerProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            infoContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: BoostViewMetrics.bottomAnchorConstant).isActive = true
        } else {
            timerProgressView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            infoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                  constant: BoostViewMetrics.bottomAnchorConstant).isActive = true
        }
        timerProgressView.layout(with: view).left().right()

        closeButton.layout().width(Metrics.closeButtonWidth).height(Metrics.closeButtonHeight)
        closeButton.layout(with: view).left()
        closeButton.layout(with: timerProgressView).below()
        closeButton.layout(with: titleContainer)
            .right(to: .left, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
            .centerY()
            .proportionalHeight()
        titleContainer.layout(with: view).centerX().right(by: -Metrics.margin, relatedBy: .lessThanOrEqual)

        infoContainer.layout(with: closeButton).below()
        infoContainer.layout(with: view).left(by: Metrics.shortMargin).right(by: -Metrics.shortMargin)

        setupTitleViewConstraints()

        setupInfoContainterConstraints()
    }

    private func setupTitleViewConstraints() {
        let titleContainerSubviews: [UIView] = [viewTitleIconView, viewTitleLabel]
        titleContainer.addSubviews(titleContainerSubviews)
        titleContainer.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: titleContainerSubviews)

        viewTitleIconView.layout().width(Metrics.bigMargin).height(Metrics.bigMargin)
        viewTitleIconView.layout(with: titleContainer).left()
        viewTitleIconView.layout(with: viewTitleLabel)
            .right(to: .left, by: -Metrics.veryShortMargin, relatedBy: .lessThanOrEqual)
            .centerY()
        viewTitleLabel.layout(with: titleContainer).right().top().bottom()
    }

    private func setupInfoContainterConstraints() {
        let infoContainerSubviews: [UIView] = [titleLabel,
                                               subtitleLabel,
                                               featuredBackgroundContainerView,
                                               boostButton]
        infoContainer.addSubviews(infoContainerSubviews)
        infoContainer.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: infoContainerSubviews)

        titleLabel.layout(with: infoContainer)
            .top(by: Metrics.margin)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)

        titleLabel.layout(with: subtitleLabel).above(by: -Metrics.veryShortMargin)

        subtitleLabel.layout(with: infoContainer)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)

        subtitleLabel.layout(with: featuredBackgroundContainerView).above(by: -Metrics.margin)

        featuredBackgroundContainerView.layout(with: infoContainer)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)

        featuredBackgroundContainerView.layout(with: boostButton).above(by: -Metrics.shortMargin)

        boostButton.layout().height(Metrics.buttonHeight)
        boostButton.layout(with: infoContainer)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)
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
        featuredBackgroundContainerView.addSubviews(bgSubviews)
        featuredBackgroundContainerView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: bgSubviews)

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
        imageContainer.addSubviews(imageContainerSubviews)
        imageContainer.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: imageContainerSubviews)

        featuredRibbonImageView.layout(with: imageContainer).top().right().proportionalWidth(multiplier: 0.25)
        featuredRibbonImageView.layout().widthProportionalToHeight()

        listingImageView.layout(with: imageContainer).fill()

        cellBottomContainer.layout().widthProportionalToHeight(multiplier: 2)
        cellBottomContainer.layout(with: imageContainer).left().right().bottom()

        cellBottomContainer.addSubview(cellBottomImageView)
        cellBottomImageView.translatesAutoresizingMaskIntoConstraints = false
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
