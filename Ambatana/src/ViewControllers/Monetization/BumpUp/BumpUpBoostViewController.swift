//
//  BumpUpBoostViewController.swift
//  LetGo
//
//  Created by Dídac on 21/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class BumpUpBoostViewController: BaseViewController {

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

    private var featuredBackgroundImageView: UIImageView = UIImageView()
    private var featuredRibbonImageView: UIImageView = UIImageView()
    private let shadowView: UIView = UIView()
    private var imageContainer: UIView = UIView()
    private var listingImageView: UIImageView = UIImageView()
    private var cellBottomContainer: UIView = UIView()
    private var cellBottomImageView: UIImageView = UIImageView()

    private var boostButton: LetgoButton = LetgoButton()

    private let featureFlags: FeatureFlaggeable
    private let viewModel: BumpUpPayViewModel

    private var timeSinceLastBump: TimeInterval
    private let maxCountdown: TimeInterval
    private var timer: Timer = Timer()

    init(viewModel: BumpUpPayViewModel,
         featureFlags: FeatureFlaggeable,
         timeSinceLastBump: TimeInterval,
         maxCountdown: TimeInterval) {
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        self.timeSinceLastBump = timeSinceLastBump
        self.maxCountdown = maxCountdown
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
    }

    // MARK: - Actions

    @objc private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @objc private dynamic func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @objc private dynamic func boostButtonPressed(_ sender: AnyObject) {
        viewModel.boostPressed()
    }

    // MARK: - Private methods

    private func startTimer() {

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
        shadowView.layer.cornerRadius = 5
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.masksToBounds = false
    }

    private func setupTopView() {
        timerProgressView.maxTime = maxCountdown
        timerProgressView.updateWith(timeLeft: maxCountdown-timeSinceLastBump)

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
        titleLabel.numberOfLines = 0
        titleLabel.minimumScaleFactor = 0.3
        subtitleLabel.text = subtitleLabelText
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = UIColor.grayText
        subtitleLabel.font = UIFont.systemFont(size: 17)
        subtitleLabel.numberOfLines = 0
        titleLabel.minimumScaleFactor = 0.3

        featuredBackgroundImageView.image = #imageLiteral(resourceName: "boost_background")
        featuredBackgroundImageView.contentMode = .top
        featuredBackgroundImageView.clipsToBounds = true
        infoContainer.layer.masksToBounds = false
        infoContainer.applyShadow(withOpacity: 0.05, radius: 5)
    }

    private func setupFakeCell() {
        featuredRibbonImageView.image = #imageLiteral(resourceName: "red_ribbon")
        featuredRibbonImageView.contentMode = .scaleAspectFit

        imageContainer.layer.masksToBounds = false
        imageContainer.applyShadow(withOpacity: 0.25, radius: 5)

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

        //        realCellHeight = featuredBackgroundImageView.height/X

        let mainSubviews: [UIView] = [timerProgressView, closeButton, titleContainer, infoContainer]
        view.addSubviews(mainSubviews)
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: mainSubviews)

        if #available(iOS 11, *) {
            timerProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            infoContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 40).isActive = true
        } else {
            timerProgressView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            infoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 40).isActive = true
        }
        timerProgressView.layout(with: view).left().right()

        closeButton.layout().width(Metrics.closeButtonWidth).height(Metrics.closeButtonHeight)
        closeButton.layout(with: view).left()
        closeButton.topAnchor.constraint(equalTo: timerProgressView.bottomAnchor).isActive = true
        closeButton.layout(with: titleContainer)
            .right(to: .left, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
            .centerY()
            .proportionalHeight()
        titleContainer.layout(with: view).centerX().right(by: -Metrics.margin, relatedBy: .lessThanOrEqual)

        infoContainer.topAnchor.constraint(equalTo: closeButton.bottomAnchor).isActive = true
        infoContainer.layout(with: view).left(by: Metrics.shortMargin).right(by: -Metrics.shortMargin)


        let titleContainerSubviews: [UIView] = [viewTitleIconView, viewTitleLabel]
        titleContainer.addSubviews(titleContainerSubviews)
        titleContainer.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: titleContainerSubviews)

        viewTitleIconView.layout().width(Metrics.bigMargin).height(Metrics.bigMargin)
        viewTitleIconView.layout(with: titleContainer).left()
        viewTitleIconView.layout(with: viewTitleLabel)
            .right(to: .left, by: -Metrics.veryShortMargin, relatedBy: .lessThanOrEqual)
            .centerY()
        viewTitleLabel.layout(with: titleContainer).right().top().bottom()

        
        let infoContainerSubviews: [UIView] = [titleLabel,
                                               subtitleLabel,
                                               featuredBackgroundImageView,
                                               shadowView,
                                               imageContainer,
                                               boostButton]
        infoContainer.addSubviews(infoContainerSubviews)
        infoContainer.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: infoContainerSubviews)

        titleLabel.layout().height(21, relatedBy: .greaterThanOrEqual)
        titleLabel.layout(with: infoContainer)
            .top(by: Metrics.bigMargin)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)

        titleLabel.layout(with: subtitleLabel).above()

        subtitleLabel.layout().height(21, relatedBy: .greaterThanOrEqual)
        subtitleLabel.layout(with: infoContainer)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)

        subtitleLabel.layout(with: featuredBackgroundImageView).above()

        featuredBackgroundImageView.layout(with: infoContainer)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)

        featuredBackgroundImageView.layout(with: boostButton).above()

        boostButton.layout().height(Metrics.buttonHeight)
        boostButton.layout(with: infoContainer)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)
            .bottom(by: -Metrics.bigMargin)

        shadowView.layout(with: imageContainer).center().fill()

        imageContainer.layout(with: infoContainer).centerX()
        imageContainer.layout(with: featuredBackgroundImageView).top(by: 20)

        imageContainer.layout(with: featuredBackgroundImageView).proportionalWidth(multiplier: 0.34)
        imageContainer.layout(with: featuredBackgroundImageView).proportionalHeight(multiplier: 0.64)
//        imageContainer.layout().widthProportionalToHeight(multiplier: 0.53)

        let imageContainerSubviews: [UIView] = [listingImageView, cellBottomContainer, featuredRibbonImageView]
        imageContainer.addSubviews(imageContainerSubviews)
        imageContainer.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: imageContainerSubviews)


        featuredRibbonImageView.layout(with: imageContainer).top().right().proportionalWidth(multiplier: 0.25)
        featuredRibbonImageView.layout().widthProportionalToHeight()


        listingImageView.layout(with: imageContainer).left().right().top().bottom()
//        listingImageView.layout(with: cellBottomContainer).above()

        cellBottomContainer.layout().widthProportionalToHeight(multiplier: 2)
        cellBottomContainer.layout(with: imageContainer).left().right().bottom()


        cellBottomContainer.addSubview(cellBottomImageView)
        cellBottomImageView.translatesAutoresizingMaskIntoConstraints = false
        cellBottomImageView.layout(with: cellBottomContainer).fill()
    }

    private func setAccessibilityIds() {
//        closeButton.set(accessibilityId: .paymentBumpUpCloseButton)
//        listingImageView.set(accessibilityId: .paymentBumpUpImage)
//        titleLabel.set(accessibilityId: .paymentBumpUpTitleLabel)
//        subtitleLabel.set(accessibilityId: .paymentBumpUpSubtitleLabel)
//        bumpUpButton.set(accessibilityId: .paymentBumpUpButton)
    }
}
