import Foundation
import RxSwift
import LGComponents

enum BumpUpType: Equatable {
    case free
    case priced
    case restore
    case hidden
    case boost(boostBannerVisible: Bool)
    case loading

    var bannerText: String? {
        switch self {
        case .free, .priced, .hidden:
            if FeatureFlags.sharedInstance.shouldChangeSellFasterNowCopyInEnglish {
                return FeatureFlags.sharedInstance.copyForSellFasterNowInEnglish.variantString
            } else {
                return R.Strings.bumpUpBannerPayTextImprovement
            }
            
        case .restore:
            return R.Strings.bumpUpErrorBumpToken
        case .boost:
            return R.Strings.bumpUpBannerBoostText
        case .loading:
            return nil
        }
    }

    var bannerIcon: UIImage? {
        switch self {
        case .free, .priced, .hidden, .boost:
            return R.Asset.Monetization.grayChevronUp.image
        case .restore, .loading:
            return nil
        }
    }

    var bannerTextIcon: UIImage? {
        switch self {
        case .free, .priced, .hidden:
            return R.Asset.Monetization.icLightning.image
        case .boost:
            return R.Asset.Monetization.icExtraBoost.image
        case .restore, .loading:
            return nil
        }
    }

    var bannerFont: UIFont {
        switch self {
        case .restore:
            return BumpUpBanner.bannerDefaultFont
        case .free, .priced, .hidden, .loading:
            return UIFont.systemSemiBoldFont(size: 17)
        case .boost:
            return UIFont.systemSemiBoldFont(size: 19)
        }
    }

    static public func ==(lhs: BumpUpType, rhs: BumpUpType) -> Bool {
        switch (lhs, rhs) {
        case (.free, .free):
            return true
        case (.priced, .priced):
            return true
        case (.restore, .restore):
            return true
        case (.hidden, .hidden):
            return true
        case (.boost(let lBannerVisible), .boost(let rBannerVisible)):
            return lBannerVisible == rBannerVisible
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }

    var isBoost: Bool {
        switch self {
        case .free, .priced, .hidden, .restore, .loading:
            return false
        case .boost:
            return true
        }
    }
}

struct BumpUpInfo {
    var type: BumpUpType
    var timeSinceLastBump: TimeInterval
    var maxCountdown: TimeInterval
    var price: String?
    var bannerInteractionBlock: (TimeInterval?) -> Void
    var buttonBlock: (TimeInterval?) -> Void

    init(type: BumpUpType,
         timeSinceLastBump: TimeInterval,
         maxCountdown: TimeInterval,
         price: String?,
         bannerInteractionBlock: @escaping (TimeInterval?) -> Void,
         buttonBlock: @escaping (TimeInterval?) -> Void) {
        self.type = type
        self.timeSinceLastBump = timeSinceLastBump
        self.maxCountdown = maxCountdown
        self.price = price
        self.bannerInteractionBlock = bannerInteractionBlock
        self.buttonBlock = buttonBlock
    }
    
    var shouldTrackBumpBannerShown: Bool {
        return self.timeSinceLastBump == 0 || self.type == .boost(boostBannerVisible: true)
    }
}

protocol BumpUpBannerBoostDelegate: class {
    func bumpUpTimerReachedZero()
    func updateBoostBannerFor(type: BumpUpType)
}

class BumpUpBanner: UIView {

    private static let bannerHeight: CGFloat = 64

    override var intrinsicContentSize: CGSize {
        switch type {
        case .free, .hidden, .restore, .priced, .loading:
            return CGSize(width: UIViewNoIntrinsicMetric,
                          height: BumpUpBanner.bannerHeight)
        case .boost(let boostBannerVisible):
            return CGSize(width: UIViewNoIntrinsicMetric,
                          height: boostBannerVisible ? 2*BumpUpBanner.bannerHeight : BumpUpBanner.bannerHeight)
        }
    }

    static let bannerDefaultFont: UIFont = UIFont.systemMediumFont(size: 15)

    static let timeLabelWidth: CGFloat = 80
    static let iconSize: CGFloat = 20
    static let iconLeftMargin: CGFloat = 15
    static let timerUpdateInterval: TimeInterval = 1

    private let containerView: UIView = UIView()
    private let improvedTextContainerView: UIView = UIView()
    private let leftIconImageView: UIImageView = UIImageView()
    private let textIconImageView: UIImageView = UIImageView()

    private let timeLabel: UILabel = UILabel()
    private let descriptionLabel: UILabel = UILabel()
    private let bumpButton = LetgoButton(withStyle: .primary(fontSize: .small))

    private let loadingContainerView: UIView = UIView()
    private var loadingLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.bumpUpBannerLoadingText
        label.font = .systemSemiBoldFont(size: 17)
        return label
    }()
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    private var leftIconWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var leftIconLeftMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var textIconWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var textIconLeftMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var timeLabelRightMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var timeLabelWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var textContainerCenterXConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var textContainerCenterYConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var bumpButtonWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private var loadingContainerCenterYConstraint: NSLayoutConstraint = NSLayoutConstraint()


    private var bannerHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()

    // Boost elements
    private var progressView: BumpUpTimerBarView = BumpUpTimerBarView()
    private var progressViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private var maxCountdown: TimeInterval = 0
    private var timer: Timer = Timer()
    private var readyToBump: Bool = false

    private(set) var type: BumpUpType = .free

    private var bannerInteractionBlock: (TimeInterval?) -> Void = { _ in }
    private var buttonBlock: (TimeInterval?) -> Void = { _ in }

    private let featureFlags: FeatureFlags = FeatureFlags.sharedInstance

    weak var delegate: BumpUpBannerBoostDelegate?

    // - Rx
    let timeIntervalLeft = Variable<TimeInterval>(0)
    let timeLabelText = Variable<String?>(nil)
    let descriptionLabelText = Variable<String?>(nil)
    let disposeBag = DisposeBag()


    // - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRx()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public Methods

    func updateInfo(info: BumpUpInfo) {
        if type == .loading && info.type != .loading {
            moveLoadingLabel()
        }
        type = info.type
        maxCountdown = info.maxCountdown

        var waitingTime: TimeInterval = 0
        switch type {
        case .loading:
            updateInfoForLoadingBanner()
        case .free:
            updateInfoForFreeBanner()
            waitingTime = info.maxCountdown
        case .priced, .hidden:
            updateInfoForPricedBannerWith(price: info.price)
            waitingTime = info.maxCountdown
        case .restore:
            updateInfoForRestoreBanner()
            waitingTime = info.maxCountdown
        case .boost(let bannerIsVisible):
            updateInfoForBoostBannerWith(bannerIsVisible: bannerIsVisible)
            waitingTime = info.maxCountdown
            progressView.maxTime = info.maxCountdown
        }
        setInitialUIForBannerWith(type: type)

        let timeShouldBeZero = info.timeSinceLastBump <= 0 || (waitingTime - info.timeSinceLastBump < 0)
        timeIntervalLeft.value = timeShouldBeZero ? 0 : waitingTime - info.timeSinceLastBump
        startCountdown()
        bumpButton.isEnabled = timeIntervalLeft.value < 1

        buttonBlock = info.buttonBlock
        bannerInteractionBlock = info.bannerInteractionBlock
    }

    private func moveLoadingLabel() {
        loadingContainerCenterYConstraint.constant = -BumpUpBanner.bannerHeight/2
        textContainerCenterYConstraint.constant = 0

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
            self?.loadingLabel.alpha = 0
        }) { [weak self] (finished) in
            self?.animateSellFasterIcon()
        }
    }

    private func animateSellFasterIcon() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.textIconImageView.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.textIconImageView.transform = CGAffineTransform.identity
            })
        }
    }

    private func updateInfoForLoadingBanner() {
        loadingLabel.alpha = 1
        loadingContainerCenterYConstraint.constant = 0
        textContainerCenterYConstraint.constant = BumpUpBanner.bannerHeight/2
        activityIndicator.startAnimating()
        bumpButton.isHidden = true
        bumpButtonWidthConstraint.isActive = false
    }

    private func updateInfoForFreeBanner() {
        activityIndicator.stopAnimating()
        bumpButtonWidthConstraint.isActive = false
        bumpButton.isHidden = true
        bumpButton.setTitle(R.Strings.bumpUpBannerFreeButtonTitle, for: .normal)
    }

    private func updateInfoForPricedBannerWith(price: String?) {
        activityIndicator.stopAnimating()
        bumpButtonWidthConstraint.isActive = false
        bumpButton.isHidden = true
        if let price = price {
            bumpButton.setTitle(price, for: .normal)
        } else {
            bumpButton.setTitle(R.Strings.bumpUpBannerFreeButtonTitle, for: .normal)
        }
    }

    private func updateInfoForRestoreBanner() {
        activityIndicator.stopAnimating()
        bumpButton.isHidden = false
        bumpButtonWidthConstraint.isActive = true
        bumpButton.setTitle(R.Strings.commonErrorRetryButton, for: .normal)
    }

    private func updateInfoForBoostBannerWith(bannerIsVisible: Bool) {
        activityIndicator.stopAnimating()
        bumpButtonWidthConstraint.isActive = false
        bumpButton.isHidden = true
        readyToBump = bannerIsVisible
    }

    func resetCountdown() {
        // Update countdown with full waiting time
        timeIntervalLeft.value = maxCountdown
        startCountdown()
    }

    func stopCountdown() {
        timer.invalidate()
    }
    
    func executeBannerInteractionBlock() {
        guard readyToBump else { return }
        bannerInteractionBlock(maxCountdown-timeIntervalLeft.value)
    }

    private func startCountdown() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: BumpUpBanner.timerUpdateInterval,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc private func bannerTapped() {
        executeBannerInteractionBlock()
    }

    @objc private func bannerSwipped() {
        executeBannerInteractionBlock()
    }

    @objc private func bumpButtonPressed() {
        guard readyToBump else { return }
        buttonBlock(nil)
    }


    // - Private Methods

    private func setupRx() {
        timeIntervalLeft.asObservable().skip(1).bind { [weak self] secondsLeft in
            guard let strongSelf = self else { return }
            let localizedText: String?
            var descriptionFont = BumpUpBanner.bannerDefaultFont

            switch strongSelf.type {
            case .boost:
                strongSelf.setupBannerItemsForBoostWith(secondsLeft: secondsLeft)
                localizedText = strongSelf.type.bannerText
                descriptionFont = strongSelf.type.bannerFont
            case .free, .priced, .hidden, .restore:
                strongSelf.setupBannerItemsForSimpleBannerWith(secondsLeft: secondsLeft)
                if secondsLeft <= 0 {
                    localizedText = strongSelf.type.bannerText
                    descriptionFont = strongSelf.type.bannerFont
                } else {
                    localizedText = R.Strings.bumpUpBannerWaitText
                }
            case .loading:
                strongSelf.setupBannerItemsForLoading()
                localizedText = strongSelf.type.bannerText
                descriptionFont = strongSelf.type.bannerFont
            }

            strongSelf.updateIconsConstraints()
            strongSelf.descriptionLabelText.value = localizedText
            strongSelf.descriptionLabel.font = descriptionFont
        }.disposed(by: disposeBag)

        timeLabelText.asObservable().bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        descriptionLabelText.asObservable().bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
    }

    private func setupBannerItemsForBoostWith(secondsLeft: TimeInterval) {
        readyToBump = false
        activityIndicator.stopAnimating()
        leftIconImageView.image = type.bannerIcon
        textIconImageView.image = type.bannerTextIcon
        progressView.updateWith(timeLeft: secondsLeft)
        timeLabelText.value = nil
        timeLabelRightMarginConstraint.constant = 0
        timeLabelWidthConstraint.constant = 0
        if let updateBannerThreshold = featureFlags.bumpUpBoost.boostBannerUIUpdateThreshold,
            secondsLeft < (maxCountdown - updateBannerThreshold) {
            readyToBump = true
            type = .boost(boostBannerVisible: true)
            delegate?.updateBoostBannerFor(type: type)
        }
        updateBannerAreasVisibilityFor(type: type)
        if secondsLeft <= 0 {
            delegate?.bumpUpTimerReachedZero()
        }
        textContainerCenterXConstraint.isActive = true
    }

    private func setupBannerItemsForSimpleBannerWith(secondsLeft: TimeInterval) {
        activityIndicator.stopAnimating()
        if secondsLeft <= 0 {
            readyToBump = true
            timer.invalidate()
            leftIconImageView.image = type.bannerIcon
            textIconImageView.image = type.bannerTextIcon
            bumpButton.isEnabled = true
            timeLabelText.value = nil
            timeLabelRightMarginConstraint.constant = 0
            timeLabelWidthConstraint.constant = 0
            textContainerCenterXConstraint.isActive = type != .restore
        } else {
            readyToBump = false
            textIconImageView.image = nil
            leftIconImageView.image = R.Asset.Monetization.clock.image
            bumpButton.isEnabled = false
            timeLabelText.value = Int(secondsLeft).secondsToCountdownFormat()
            timeLabelRightMarginConstraint.constant = -Metrics.shortMargin
            timeLabelWidthConstraint.constant = BumpUpBanner.timeLabelWidth
            textContainerCenterXConstraint.isActive = false
        }
    }

    private func setupBannerItemsForLoading() {
        activityIndicator.startAnimating()
        readyToBump = false
        timer.invalidate()
        leftIconImageView.image = type.bannerIcon
        textIconImageView.image = type.bannerTextIcon
        bumpButton.isEnabled = false
        timeLabelText.value = nil
        timeLabelRightMarginConstraint.constant = 0
        timeLabelWidthConstraint.constant = 0
        textContainerCenterXConstraint.isActive = true
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        
        timeLabel.numberOfLines = 1
        timeLabel.adjustsFontSizeToFitWidth = false
        timeLabel.textAlignment = .center
        timeLabel.textColor = UIColor.primaryColorHighlighted
        timeLabel.font = UIFont.systemMediumFont(size: 17)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = UIColor.blackText
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = BumpUpBanner.bannerDefaultFont
        
        leftIconImageView.image = R.Asset.Monetization.redChevronUp.image
        leftIconImageView.contentMode = .scaleAspectFit

        textIconImageView.image = nil
        textIconImageView.contentMode = .scaleAspectFit
        
        bumpButton.addTarget(self, action: #selector(bumpButtonPressed), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bannerTapped))
        addGestureRecognizer(tapGesture)
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(bannerSwipped))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)

        activityIndicator.hidesWhenStopped = true
    }

    private func setupConstraints() {

        let mainViews: [UIView] = [containerView, progressView]
        addSubviewsForAutoLayout(mainViews)
        
        progressView.layout().height(BumpUpTimerBarViewMetrics.height, constraintBlock: { [weak self] in
            self?.progressViewHeightConstraint = $0
        })
        progressView.layout(with: self).left().right().top()
        progressView.layout(with: containerView).above()
        containerView.layout(with: self).left().right().bottom()
        containerView.layout().height(BumpUpTimerBarViewMetrics.height, constraintBlock: { [weak self] in
            self?.bannerHeightConstraint = $0
        })

        let improvedTextViews: [UIView] = [textIconImageView, descriptionLabel]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: improvedTextViews)
        improvedTextContainerView.addSubviews(improvedTextViews)

        let subviews: [UIView] = [leftIconImageView, timeLabel, improvedTextContainerView, bumpButton,
                                  loadingContainerView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        containerView.addSubviews(subviews)

        let loadingViews: [UIView] = [loadingLabel, activityIndicator]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: loadingViews)
        loadingContainerView.addSubviews(loadingViews)

        loadingContainerView.layout(with: containerView).centerX()
        loadingContainerView.layout(with: containerView).centerY(constraintBlock: { [weak self] in
            self?.loadingContainerCenterYConstraint = $0
        })

        activityIndicator.layout(with: loadingContainerView).left()
        activityIndicator.layout(with: loadingContainerView).centerY()
        activityIndicator.layout(with: loadingLabel).right(to: .left, by: -Metrics.shortMargin)

        loadingLabel.layout(with: loadingContainerView).top()
        loadingLabel.layout(with: loadingContainerView).bottom()
        loadingLabel.layout(with: loadingContainerView).right()

        leftIconImageView.layout().width(BumpUpBanner.iconSize, constraintBlock: { [weak self] in
            self?.leftIconWidthConstraint = $0
        }).height(BumpUpBanner.iconSize)

        leftIconImageView.layout(with: containerView).left(by: BumpUpBanner.iconLeftMargin, constraintBlock: { [weak self] in
            self?.leftIconLeftMarginConstraint = $0
        })
        leftIconImageView.layout(with: timeLabel).right(to: .left, by: -Metrics.shortMargin)
        leftIconImageView.layout(with: containerView).centerY()

        timeLabel.layout(with: containerView).top()
        timeLabel.layout(with: containerView).bottom()
        timeLabel.layout().width(BumpUpBanner.timeLabelWidth, relatedBy: .greaterThanOrEqual, constraintBlock: { [weak self] in
            self?.timeLabelWidthConstraint = $0
        })
        timeLabel.layout(with: improvedTextContainerView).right(to: .left, by: -Metrics.shortMargin, constraintBlock: { [weak self] in
            self?.timeLabelRightMarginConstraint = $0
        })
        timeLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

        improvedTextContainerView.layout(with: containerView).centerY(constraintBlock: { [weak self] in
            self?.textContainerCenterYConstraint = $0
        })
        improvedTextContainerView.layout(with: containerView).centerX(constraintBlock: { [weak self] in
            self?.textContainerCenterXConstraint = $0
        })
        improvedTextContainerView.layout(with: bumpButton).right(to: .left, by: -Metrics.shortMargin, relatedBy: .lessThanOrEqual)
        improvedTextContainerView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)

        textIconImageView.layout().width(BumpUpBanner.iconSize, constraintBlock: { [weak self] in
            self?.textIconWidthConstraint = $0
        }).height(BumpUpBanner.iconSize)
        textIconImageView.layout(with: improvedTextContainerView).left()
        textIconImageView.layout(with: improvedTextContainerView).centerY()
        textIconImageView.layout(with: descriptionLabel).right(to: .left, by: -Metrics.shortMargin, constraintBlock:{ [weak self] in
            self?.textIconLeftMarginConstraint = $0
        })

        descriptionLabel.layout(with: improvedTextContainerView).top()
        descriptionLabel.layout(with: improvedTextContainerView).bottom()
        descriptionLabel.layout(with: improvedTextContainerView).right()
        descriptionLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

        bumpButton.layout(with: containerView)
            .top(by: Metrics.shortMargin)
            .bottom(by: -Metrics.shortMargin)
            .right(by: -Metrics.margin)
        bumpButton.layout().width(BumpUpBanner.timeLabelWidth, relatedBy: .greaterThanOrEqual, constraintBlock: { [weak self] in
            self?.bumpButtonWidthConstraint = $0
        })
        bumpButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    }

    private func updateIconsConstraints() {
        let leftIconWidth: CGFloat = leftIconImageView.image != nil ? BumpUpBanner.iconSize : 0
        let leftIconLeftMargin: CGFloat = leftIconImageView.image != nil ? BumpUpBanner.iconLeftMargin : 0

        leftIconWidthConstraint.constant = leftIconWidth
        leftIconLeftMarginConstraint.constant = leftIconLeftMargin

        let textIconWidth: CGFloat = textIconImageView.image != nil ? BumpUpBanner.iconSize : 0
        let textIconLeftMargin: CGFloat = textIconImageView.image != nil ? -Metrics.shortMargin : 0

        textIconWidthConstraint.constant = textIconWidth
        textIconLeftMarginConstraint.constant = textIconLeftMargin

        layoutIfNeeded()
    }

    private func setInitialUIForBannerWith(type: BumpUpType) {
        switch type {
        case .free, .hidden, .restore, .priced, .loading:
            hideProgressBar()
        case .boost(let boostBannerVisible):
            showProgressBar(itHasBanner: boostBannerVisible)
        }
    }

    private func updateBannerAreasVisibilityFor(type: BumpUpType) {
        switch type {
        case .free, .hidden, .restore, .loading:
            hideProgressBar()
        case .priced:
            if featureFlags.bumpUpBoost.isActive {
                showProgressBar(itHasBanner: false)
            } else {
                hideProgressBar()
            }
        case .boost(let boostBannerVisible):
            showProgressBar(itHasBanner: boostBannerVisible)
        }
    }

    private func showProgressBar(itHasBanner: Bool) {
        progressViewHeightConstraint.constant = BumpUpTimerBarViewMetrics.height
        bannerHeightConstraint.constant = itHasBanner ? CarouselUI.bannerHeight : 0
        containerView.isHidden = !itHasBanner
        progressView.isHidden = false
        layoutIfNeeded()
    }

    private func hideProgressBar() {
        progressViewHeightConstraint.constant = 0
        bannerHeightConstraint.constant = CarouselUI.bannerHeight
        containerView.isHidden = false
        progressView.isHidden = true
        layoutIfNeeded()
    }

    @objc private dynamic func updateTimer() {
        timeIntervalLeft.value = timeIntervalLeft.value-BumpUpBanner.timerUpdateInterval
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .bumpUpBanner)
        bumpButton.set(accessibilityId: .bumpUpBannerButton)
        timeLabel.set(accessibilityId: .bumpUpBannerLabel)
    }
}
