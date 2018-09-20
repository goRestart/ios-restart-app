import Foundation
import LGComponents
import LGCoreKit
import RxSwift


final class BumpUpMultiDayInfoViewController: BaseViewController {

    private enum Layout {
        static let closeButtonHeight: CGFloat = 40
    }

    private let viewModel: BumpUpPayViewModel

    private var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Asset.Monetization.grayChevronDown.image, for: .normal)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()
    private var timerProgressView: BumpUpTimerBarView = BumpUpTimerBarView()

    private var oneDayView: BumpUpMultiDayView = BumpUpMultiDayView()
    private var threeDaysView: BumpUpMultiDayView = BumpUpMultiDayView()
    private var sevenDaysView: BumpUpMultiDayView = BumpUpMultiDayView()

    private var bumpViewsArray: [BumpUpMultiDayView] = []

    private var selectedFeaturePurchaseType: FeaturePurchaseType

    private var disposeBag: DisposeBag?


    init(viewModel: BumpUpPayViewModel,
         selectedFeaturePurchaseType: FeaturePurchaseType) {
        self.viewModel = viewModel
        self.selectedFeaturePurchaseType = selectedFeaturePurchaseType
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setAccessibilityIds()
        viewModel.multiDayInfoViewLoaded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRx()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bumpViewsArray.forEach { $0.updateLayouts() }
    }

    private func setupRx() {
        let disposeBag = DisposeBag()

        viewModel.timeIntervalLeft.asDriver().drive(onNext: { [weak self] timeIntervalLeft in
            guard let timeIntervalLeft = timeIntervalLeft else { return }
            self?.timerProgressView.updateWith(timeLeft: timeIntervalLeft)
        }).disposed(by: disposeBag)

        self.disposeBag = disposeBag
    }

    private func setupUI() {
        view.backgroundColor = UIColor.veryLightGray
        createBumpViews()
        addSwipeDownGestureToView()
    }

    private func addSwipeDownGestureToView() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    @objc private dynamic func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @objc private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    private func createBumpViews() {
        let imageUrl = viewModel.listing.images.first?.fileURL
        oneDayView = BumpUpMultiDayView.bumpUpMultiDayViewFor(featurePurchaseType: .bump,
                                                              priceString: nil,
                                                              status: .collapsed,
                                                              listingImageUrl: imageUrl,
                                                              buttonAction: nil)

        threeDaysView = BumpUpMultiDayView.bumpUpMultiDayViewFor(featurePurchaseType: .threeDays,
                                                                 priceString: nil,
                                                                 status: .collapsed,
                                                                 listingImageUrl: imageUrl,
                                                                 buttonAction: nil)

        sevenDaysView = BumpUpMultiDayView.bumpUpMultiDayViewFor(featurePurchaseType: .sevenDays,
                                                                 priceString: nil,
                                                                 status: .collapsed,
                                                                 listingImageUrl: imageUrl,
                                                                 buttonAction: nil)

        bumpViewsArray.append(contentsOf: [oneDayView, threeDaysView, sevenDaysView])

        updateViewsInfo()
    }

    private func updateViewsInfo() {
        timerProgressView.maxTime = viewModel.maxCountdown
        timerProgressView.updateWith(timeLeft: viewModel.maxCountdown)

        switch selectedFeaturePurchaseType {
        case .bump, .boost:
            timerProgressView.updateUIWith(type: .oneDay)
            oneDayView.updateTextsForInfo(infoTitle: R.Strings.bumpUpViewMultiDayInfoTitle, infoSubtitle: R.Strings.bumpUpViewMultiDayInfo1DaySubtitle)
            oneDayView.expand()
            viewModel.oneDayBumpSelected()
        case .threeDays:
            timerProgressView.updateUIWith(type: .threeDays)
            threeDaysView.updateTextsForInfo(infoTitle: R.Strings.bumpUpViewMultiDayInfoTitle, infoSubtitle: R.Strings.bumpUpViewMultiDayInfo3DaysSubtitle)
            threeDaysView.expand()
            viewModel.threeDaysBumpSelected()
        case .sevenDays:
            timerProgressView.updateUIWith(type: .sevenDays)
            sevenDaysView.updateTextsForInfo(infoTitle: R.Strings.bumpUpViewMultiDayInfoTitle, infoSubtitle: R.Strings.bumpUpViewMultiDayInfo7DaysSubtitle)
            sevenDaysView.expand()
            viewModel.sevenDaysBumpSelected()
        }
    }

    private func setupConstraints() {
        let firstLevelViews: [UIView] = [closeButton, timerProgressView] + bumpViewsArray

        view.addSubviewsForAutoLayout(firstLevelViews)

        let constraints = [
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.veryShortMargin),
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: Metrics.shortMargin),
            timerProgressView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            timerProgressView.leadingAnchor.constraint(greaterThanOrEqualTo: closeButton.trailingAnchor),
            timerProgressView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Metrics.shortMargin),
            timerProgressView.heightAnchor.constraint(equalToConstant: BumpUpTimerBarViewMetrics.height),

            oneDayView.topAnchor.constraint(equalTo: timerProgressView.bottomAnchor, constant: Metrics.margin),
            oneDayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            oneDayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),

            threeDaysView.topAnchor.constraint(equalTo: oneDayView.bottomAnchor, constant: Metrics.shortMargin),
            threeDaysView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            threeDaysView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),

            sevenDaysView.topAnchor.constraint(equalTo: threeDaysView.bottomAnchor, constant: Metrics.shortMargin),
            sevenDaysView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            sevenDaysView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
            sevenDaysView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.shortMargin)
        ]
        NSLayoutConstraint.activate(constraints)

        closeButton.layout().height(Layout.closeButtonHeight).widthProportionalToHeight()


    }

    private func setAccessibilityIds() {
        closeButton.set(accessibilityId: .multiDayBumpInfoCloseButton)
        timerProgressView.set(accessibilityId: .multiDayBumpInfoTimerBar)
        oneDayView.set(accessibilityId: .multiDayBumpInfo1DayItem)
        threeDaysView.set(accessibilityId: .multiDayBumpInfo3DaysItem)
        sevenDaysView.set(accessibilityId: .multiDayBumpInfo7DaysItem)
    }
}

