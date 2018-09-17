import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa
import GoogleMobileAds

struct UserDetail {
    let userInfo: ListingVMUserInfo
    let isPro: Bool
}

final class ListingDetailViewModel: BaseViewModel {
    var navigator: ListingFullDetailNavigator?
    lazy var listingViewModel: ListingViewModel = maker.build(listing: listing, visitSource: visitSource)

    private let maker: ListingViewModelAssembly
    private let listing: Listing
    private let visitSource: EventParameterListingVisitSource
    private let featureFlags: FeatureFlaggeable

    var deckMapData: DeckMapData? {
        guard let location = listingViewModel.productInfo.value?.location?.coordinates2DfromLocation() else { return nil }
        let shouldShowExactLocation = listingViewModel.showExactLocationOnMap.value
        return DeckMapData(location: location, shouldHighlightCenter: shouldShowExactLocation)
    }

    // Ads
    private let adsImpressionConfigurable: AdsImpressionConfigurable
    var dfpAdUnitId: String {
        return featureFlags.moreInfoDFPAdUnitId
    }
    var adActive: Bool {
        return !listingViewModel.isMine && userShouldSeeAds
    }
    var multiAdRequestActive: Bool {
        return featureFlags.multiAdRequestMoreInfo.isActive
    }
    var userShouldSeeAds: Bool {
        return adsImpressionConfigurable.shouldShowAdsForUser
    }
    var dfpContentURL: String? {
        guard let listingId = listingViewModel.listing.value.objectId else { return nil }
        return LetgoURLHelper.buildProductURL(listingId: listingId, isLocalized: true)?.absoluteString
    }
    let sideMargin: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone6) ? Metrics.margin : 0
    var currentAdRequestType: AdRequestType? {
        return adActive ? .dfp : nil
    }
    var adBannerTrackingStatus: AdBannerTrackingStatus? = nil

    convenience init(withListing listing: Listing,
                     viewModelMaker: ListingViewModelAssembly,
                     visitSource: EventParameterListingVisitSource) {
        self.init(withListing: listing,
                  viewModelMaker: viewModelMaker,
                  visitSource: visitSource,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsImpressionConfigurable: LGAdsImpressionConfigurable())
    }

    init(withListing listing: Listing,
         viewModelMaker: ListingViewModelAssembly,
         visitSource: EventParameterListingVisitSource,
         featureFlags: FeatureFlaggeable,
         adsImpressionConfigurable: AdsImpressionConfigurable) {
        self.listing = listing
        self.visitSource = visitSource
        self.featureFlags = featureFlags
        self.adsImpressionConfigurable = adsImpressionConfigurable
        self.maker = viewModelMaker
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            listingViewModel.active = true
        }
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        listingViewModel.active = false
    }

    func closeDetail() {
        navigator?.closeDetail()
    }
}

extension ListingDetailViewModel {
    func didReceiveAd(bannerTopPosition: CGFloat,
                      bannerBottomPosition: CGFloat,
                      screenHeight: CGFloat,
                      bannerSize: CGSize) {

        let isMine = EventParameterBoolean(bool: listingViewModel.isMine)
        let adShown: EventParameterBoolean = .trueParameter
        let adType = currentAdRequestType?.trackingParamValueFor(size: multiAdRequestActive ? bannerSize : nil)
        let visibility = EventParameterAdVisibility(bannerTopPosition: bannerTopPosition,
                                                    bannerBottomPosition: bannerBottomPosition,
                                                    screenHeight: screenHeight)
        let errorReason: EventParameterAdSenseRequestErrorReason? = nil

        adBannerTrackingStatus = AdBannerTrackingStatus(isMine: isMine,
                                                        adShown: adShown,
                                                        adType: adType,
                                                        queryType: nil,
                                                        query: nil,
                                                        visibility: visibility,
                                                        errorReason: errorReason)

        listingViewModel.trackVisitMoreInfo(isMine: isMine,
                                                    adShown: adShown,
                                                    adType: adType,
                                                    queryType: nil,
                                                    query: nil,
                                                    visibility: visibility,
                                                    errorReason: errorReason)
    }

    func didFailToReceiveAd(withErrorCode code: GADErrorCode, bannerSize: CGSize) {

        let isMine = EventParameterBoolean(bool: listingViewModel.isMine)
        let adShown: EventParameterBoolean = .falseParameter
        let adType = currentAdRequestType?.trackingParamValueFor(size: multiAdRequestActive ? bannerSize : nil)
        let visibility: EventParameterAdVisibility? = nil
        let errorReason: EventParameterAdSenseRequestErrorReason? = EventParameterAdSenseRequestErrorReason(errorCode: code)

        adBannerTrackingStatus = AdBannerTrackingStatus(isMine: isMine,
                                                        adShown: adShown,
                                                        adType: adType,
                                                        queryType: nil,
                                                        query: nil,
                                                        visibility: visibility,
                                                        errorReason: errorReason)

        listingViewModel.trackVisitMoreInfo(isMine: isMine,
                                                    adShown: adShown,
                                                    adType: adType,
                                                    queryType: nil,
                                                    query: nil,
                                                    visibility: visibility,
                                                    errorReason: errorReason)
    }

    func adAlreadyRequestedWithStatus(adBannerTrackingStatus status: AdBannerTrackingStatus) {
        listingViewModel.trackVisitMoreInfo(isMine: status.isMine,
                                                    adShown: status.adShown,
                                                    adType: status.adType,
                                                    queryType: status.queryType,
                                                    query: status.query,
                                                    visibility: status.visibility,
                                                    errorReason: status.errorReason)
    }

    func adTapped(typePage: EventParameterTypePage, willLeaveApp: Bool, bannerSize: CGSize) {
        let adType = currentAdRequestType?.trackingParamValueFor(size: multiAdRequestActive ? bannerSize : nil)
        let isMine = EventParameterBoolean(bool: listingViewModel.isMine)
        let willLeave = EventParameterBoolean(bool: willLeaveApp)
        listingViewModel.trackAdTapped(adType: adType,
                                               isMine: isMine,
                                               queryType: nil,
                                               query: nil,
                                               willLeaveApp: willLeave,
                                               typePage: typePage)
    }
}

typealias ListingDetailStats = (views: Int?, favs: Int?, posted: Date?)
typealias ListingDetailLocation = (location: LGLocationCoordinates2D?, address: String?, showExactLocation: Bool)

extension ListingDetailViewModel: ReactiveCompatible { }

extension Reactive where Base: ListingDetailViewModel {
    var media: Driver<[Media]> { return base.listingViewModel.productMedia.asDriver() }
    var title: Driver<String?> { return base.listingViewModel.productInfo.asDriver().map { return $0?.title } }
    var price: Driver<String?> { return base.listingViewModel.productInfo.asDriver().map { return $0?.price } }
    var detail: Driver<String?> { return base.listingViewModel.listing.asDriver().map { return $0.description }}
    var stats: Driver<ListingDetailStats?> {
        let views = base.listingViewModel.listingStats.asObservable().map { $0?.viewsCount }
        let favs = base.listingViewModel.listingStats.asObservable().map { $0?.favouritesCount }
        let date = base.listingViewModel.productInfo.asObservable().map { $0?.creationDate }

        return Observable.combineLatest(views, favs, date) { ($0, $1, $2) }.asDriver(onErrorJustReturn: nil)
    }
    var user: Driver<UserDetail?> {
        let isPro = base.listingViewModel.seller.asObservable().map { $0?.isProfessional ?? false }
        let userInfo = base.listingViewModel.userInfo.asObservable()

        let userDetail: Observable<UserDetail?> = Observable.combineLatest(isPro, userInfo) { ($0, $1) }
            .map { (isPro, userInfo) in
                return UserDetail.init(userInfo: userInfo, isPro: isPro)
        }

        return userDetail.asDriver(onErrorJustReturn: nil)
    }

    var location: Driver<ListingDetailLocation?> {
        let location = base.listingViewModel.productInfo.asObservable().map { return $0?.location }
        let address = base.listingViewModel.productInfo.asObservable().map { $0?.address }
        let showExactLocation = base.listingViewModel.showExactLocationOnMap.asObservable()
        return Observable
            .combineLatest(location, address, showExactLocation) { ($0, $1, $2) }
            .asDriver(onErrorJustReturn: nil)
    }

}
