import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class BumpUpPayViewModel: BaseViewModel {

    var isBoost: Bool = false {
        didSet {
            if isBoost { selectedPurchaseType = .boost }
        }
    }
    var paymentEnabled: Bool {
        return (selectedPurchaseType == .bump || selectedPurchaseType == .boost)
    }

    var listing: Listing
    let maxCountdown: TimeInterval
    private let timeIntervalLeftRelay = BehaviorRelay<TimeInterval?>(value: nil)
    var timeIntervalLeft: Driver<TimeInterval?> {
        return timeIntervalLeftRelay.asDriver()
    }
    private var timer: Timer = Timer()
    
    private let typePage: EventParameterTypePage?

    var boostIsEnabled: Bool {
        guard let timeIntervalLeft = timeIntervalLeftRelay.value else { return false }
        return timeIntervalLeft < (maxCountdown - BumpUpBanner.boostBannerUIUpdateThreshold)
    }

    var price: String {
        return purchaseableProduct?.formattedCurrencyPrice ?? ""
    }
    private var purchaseableProduct: PurchaseableProduct? {
        switch selectedPurchaseType {
        case .bump:
            return oneDayBumpData?.purchaseableProduct
        case .threeDays:
            return threeDaysBumpData?.purchaseableProduct
        case .sevenDays:
            return sevenDaysBumpData?.purchaseableProduct
        case .boost:
            return oneDayBoostData?.purchaseableProduct
        }
    }
    private var letgoItemId: String? {
        switch selectedPurchaseType {
        case .bump:
            return oneDayBumpData?.letgoItemId
        case .threeDays:
            return threeDaysBumpData?.letgoItemId
        case .sevenDays:
            return sevenDaysBumpData?.letgoItemId
        case .boost:
            return oneDayBoostData?.letgoItemId
        }
    }
    private var storeProductId: String? {
        switch selectedPurchaseType {
        case .bump:
            return oneDayBumpData?.storeProductId
        case .threeDays:
            return threeDaysBumpData?.storeProductId
        case .sevenDays:
            return sevenDaysBumpData?.storeProductId
        case .boost:
            return oneDayBoostData?.storeProductId
        }
    }
    let purchases: [BumpUpProductData]
    private let purchasesShopper: PurchasesShopper
    private let tracker: Tracker

    var navigator: BumpUpNavigator?

    private var selectedPurchaseType: FeaturePurchaseType = .bump

    var oneDayBumpData: BumpUpProductData? {
        return purchases.filter({ $0.featurePurchase?.purchaseType == .bump }).first
    }

    var threeDaysBumpData: BumpUpProductData? {
        return purchases.filter({ $0.featurePurchase?.purchaseType == .threeDays }).first
    }

    var sevenDaysBumpData: BumpUpProductData? {
        return purchases.filter({ $0.featurePurchase?.purchaseType == .sevenDays }).first
    }

    var oneDayBoostData: BumpUpProductData? {
        return purchases.filter({ $0.featurePurchase?.purchaseType == .boost }).first
    }

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(listing: Listing,
                     purchases: [BumpUpProductData],
                     typePage: EventParameterTypePage?,
                     maxCountdown: TimeInterval,
                     timeSinceLastBump: TimeInterval?) {
        let purchasesShopper = LGPurchasesShopper.sharedInstance
        self.init(listing: listing,
                  purchases: purchases,
                  purchasesShopper: purchasesShopper,
                  typePage: typePage,
                  maxCountdown: maxCountdown,
                  timeSinceLastBump: timeSinceLastBump,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(listing: Listing,
         purchases: [BumpUpProductData],
         purchasesShopper: PurchasesShopper,
         typePage: EventParameterTypePage?,
         maxCountdown: TimeInterval,
         timeSinceLastBump: TimeInterval?,
         tracker: Tracker) {
        self.listing = listing
        self.purchases = purchases
        self.purchasesShopper = purchasesShopper
        self.tracker = tracker
        self.typePage = typePage
        self.maxCountdown = maxCountdown
        if let timeSinceLastBump = timeSinceLastBump {
            self.timeIntervalLeftRelay.accept(maxCountdown-timeSinceLastBump)
        } else {
            self.timeIntervalLeftRelay.accept(nil)
        }
        super.init()
        self.setupRx()
    }

    func viewDidAppear() {
        let trackerEvent = TrackerEvent.bumpBannerInfoShown(type: EventParameterBumpUpType.paid,
                                                            listingId: listing.objectId,
                                                            storeProductId: storeProductId,
                                                            typePage: typePage,
                                                            isBoost: EventParameterBoolean(bool: isBoost),
                                                            paymentEnabled: EventParameterBoolean(bool: paymentEnabled))
        tracker.trackEvent(trackerEvent)
    }

    func boostViewLoaded() {
        startTimer()
    }

    func multiDayInfoViewLoaded() {
        startTimer()
    }

    
    // MARK: - Public methods

    func oneDayBumpSelected() {
        selectedPurchaseType = .bump
    }

    func threeDaysBumpSelected() {
        selectedPurchaseType = .threeDays
    }

    func sevenDaysBumpSelected() {
        selectedPurchaseType = .sevenDays
    }

    func bumpUpPressed() {
        navigator?.bumpUpDidFinish(completion: { [weak self] in
            self?.bumpUpProduct()
        })
    }

    func boostPressed() {
        navigator?.bumpUpDidFinish(completion: { [weak self] in
            self?.boostProduct()
        })
    }

    func closeActionPressed() {
        navigator?.bumpUpDidCancel()
    }

    func timerReachedZero() {
        timer.invalidate()
        navigator?.bumpUpDidCancel()
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
        guard let timeIntervalLeft = timeIntervalLeftRelay.value else { return }
        timeIntervalLeftRelay.accept(timeIntervalLeft-BumpUpBoostViewController.timerUpdateInterval)
    }

    private func setupRx() {
        timeIntervalLeft.asDriver().drive(onNext: { [weak self] timeIntervalLeft in
            guard let timeIntervalLeft = timeIntervalLeft else { return }
            if timeIntervalLeft == 0 {
                self?.timerReachedZero()
            }
        }).disposed(by: disposeBag)

    }

    private func bumpUpProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(purchaseableProduct)")
        guard let purchaseableProduct = purchaseableProduct,
            let listingId = listing.objectId,
            let letgoItemId = letgoItemId else { return }

        let selectedPurchase = purchases.filter({ $0.featurePurchase?.purchaseType == selectedPurchaseType }).first
        let selectedPurchaseMaxCountDown = selectedPurchase?.featurePurchase?.featureDuration

        purchasesShopper.requestPayment(forListingId: listingId,
                                        appstoreProduct: purchaseableProduct,
                                        letgoItemId: letgoItemId,
                                        maxCountdown: selectedPurchaseMaxCountDown ?? maxCountdown,
                                        typePage: typePage,
                                        featurePurchaseType: selectedPurchaseType)
    }

    private func boostProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Boost with purchase: \(purchaseableProduct)")
        guard let purchaseableProduct = purchaseableProduct,
            let listingId = listing.objectId,
            let letgoItemId = letgoItemId else { return }
        purchasesShopper.requestPayment(forListingId: listingId,
                                        appstoreProduct: purchaseableProduct,
                                        letgoItemId: letgoItemId,
                                        maxCountdown: maxCountdown,
                                        typePage: typePage,
                                        featurePurchaseType: .boost)
    }
}
