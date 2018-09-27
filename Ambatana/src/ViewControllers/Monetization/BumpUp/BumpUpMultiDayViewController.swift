import Foundation
import LGComponents
import LGCoreKit


final class BumpUpMultiDayViewController: BaseViewController {

    private enum Layout {
        static let closeButtonHeight: CGFloat = 40
    }

    private let viewModel: BumpUpPayViewModel
    private let featureFlags: FeatureFlaggeable

    private var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Asset.Monetization.grayChevronDown.image, for: .normal)
        return button
    }()
    private var lightningImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.Monetization.icLightning.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var viewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemSemiBoldFont(size: 17)
        label.text = R.Strings.bumpUpViewMultiDayTitle
        label.textColor = UIColor.blackText
        label.numberOfLines = 1
        return label
    }()
    private var viewTitleContainer: UIView = UIView()

    private var oneDayView: BumpUpMultiDayView = BumpUpMultiDayView()
    private var threeDaysView: BumpUpMultiDayView = BumpUpMultiDayView()
    private var sevenDaysView: BumpUpMultiDayView = BumpUpMultiDayView()

    private var bumpViewsArray: [BumpUpMultiDayView] = []

    var initialFeaturePurchaseType: FeaturePurchaseType {
        switch featureFlags.multiDayBumpUp {
        case .show1Day, .control, .baseline:
            viewModel.oneDayBumpSelected()
            return .bump
        case .show3Days:
            viewModel.threeDaysBumpSelected()
            return .threeDays
        case .show7Days:
            viewModel.sevenDaysBumpSelected()
            return .sevenDays
        }
    }

    init(viewModel: BumpUpPayViewModel,
         featureFlags: FeatureFlaggeable) {
        self.viewModel = viewModel
        self.featureFlags = featureFlags
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bumpViewsArray.forEach { $0.updateLayouts() }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.veryLightGray
        createBumpViews()
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }

    @objc private dynamic func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    private func createBumpViews() {
        if let oneDayData = viewModel.oneDayBumpData {
            oneDayView = createBumpViewWith(data: oneDayData)
            let tapOneDay = UITapGestureRecognizer(target: self, action: #selector(oneDayBumpViewTapped))
            oneDayView.addGestureRecognizer(tapOneDay)
        }
        if let threeDaysData = viewModel.threeDaysBumpData {
            threeDaysView = createBumpViewWith(data: threeDaysData)
            let tapThreeDays = UITapGestureRecognizer(target: self, action: #selector(threeDaysBumpViewTapped))
            threeDaysView.addGestureRecognizer(tapThreeDays)
        }
        if let sevenDaysData = viewModel.sevenDaysBumpData {
            sevenDaysView = createBumpViewWith(data: sevenDaysData)
            let tapSevenDays = UITapGestureRecognizer(target: self, action: #selector(sevenDaysBumpViewTapped))
            sevenDaysView.addGestureRecognizer(tapSevenDays)
        }
    }

    private func createBumpViewWith(data: BumpUpProductData) -> BumpUpMultiDayView {
        guard let purchaseType = data.featurePurchase?.purchaseType else { return BumpUpMultiDayView() }
        let priceString = data.purchaseableProduct.formattedCurrencyPrice
        let status: BumpUpMultiDayViewStatus = initialFeaturePurchaseType == purchaseType ? .expanded : .collapsed
        let imageUrl = viewModel.listing.images.first?.fileURL
        let view = BumpUpMultiDayView.bumpUpMultiDayViewFor(featurePurchaseType: purchaseType,
                                                            priceString: priceString,
                                                            status: status,
                                                            listingImageUrl: imageUrl,
                                                            buttonAction: featureButtonTapped)
        bumpViewsArray.append(view)
        return view
    }

    @objc private func oneDayBumpViewTapped() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.oneDayView.expand()
            self?.threeDaysView.collapse()
            self?.sevenDaysView.collapse()
            self?.viewModel.oneDayBumpSelected()
            self?.view.layoutIfNeeded()
        })
    }

    @objc private func threeDaysBumpViewTapped() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.threeDaysView.expand()
            self?.sevenDaysView.collapse()
            self?.oneDayView.collapse()
            self?.viewModel.threeDaysBumpSelected()
            self?.view.layoutIfNeeded()
        })
    }

    @objc private func sevenDaysBumpViewTapped() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.sevenDaysView.expand()
            self?.oneDayView.collapse()
            self?.threeDaysView.collapse()
            self?.viewModel.sevenDaysBumpSelected()
            self?.view.layoutIfNeeded()
        })
    }

    func featureButtonTapped() {
        viewModel.bumpUpPressed()
    }

    private func setupConstraints() {
        let firstLevelViews: [UIView] = [closeButton, viewTitleContainer] + bumpViewsArray

        view.addSubviewsForAutoLayout(firstLevelViews)

        let constraints = [
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.shortMargin),
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: Metrics.shortMargin),
            viewTitleContainer.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            viewTitleContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewTitleContainer.leadingAnchor.constraint(greaterThanOrEqualTo: closeButton.trailingAnchor, constant: Metrics.shortMargin),
            viewTitleContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Metrics.shortMargin),

            oneDayView.topAnchor.constraint(equalTo: viewTitleContainer.bottomAnchor, constant: Metrics.margin),
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

        viewTitleContainer.addSubviewsForAutoLayout([lightningImageView, viewTitleLabel])
         let titleConstraints = [
            lightningImageView.leadingAnchor.constraint(equalTo: viewTitleContainer.leadingAnchor),
            lightningImageView.topAnchor.constraint(equalTo: viewTitleContainer.topAnchor),
            lightningImageView.bottomAnchor.constraint(equalTo: viewTitleContainer.bottomAnchor),
            lightningImageView.trailingAnchor.constraint(equalTo: viewTitleLabel.leadingAnchor, constant: -Metrics.shortMargin),
            lightningImageView.centerYAnchor.constraint(equalTo: viewTitleLabel.centerYAnchor),
            viewTitleLabel.topAnchor.constraint(equalTo: viewTitleContainer.topAnchor),
            viewTitleLabel.bottomAnchor.constraint(equalTo: viewTitleContainer.bottomAnchor),
            viewTitleLabel.trailingAnchor.constraint(equalTo: viewTitleContainer.trailingAnchor)
        ]
        NSLayoutConstraint.activate(titleConstraints)

    }

    private func setAccessibilityIds() {
        closeButton.set(accessibilityId: .multiDayBumpCloseButton)
        viewTitleLabel.set(accessibilityId: .multiDayBumpTitleLabel)
        oneDayView.set(accessibilityId: .multiDayBump1DayItem)
        threeDaysView.set(accessibilityId: .multiDayBump3DaysItem)
        sevenDaysView.set(accessibilityId: .multiDayBump7DaysItem)
    }
}
