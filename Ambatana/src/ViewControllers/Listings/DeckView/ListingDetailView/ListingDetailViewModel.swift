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
    let listingViewModel: ListingCardViewModel

    var navBarButtons: [UIAction] { return listingViewModel.navBarActions }

    private let featureFlags: FeatureFlaggeable
    private let visitSource: EventParameterListingVisitSource
    
    var deckMapData: DeckMapData? {
        guard let location = listingViewModel.location?.coordinates2DfromLocation() else {
            return nil
        }
        let shouldShowExactLocation = listingViewModel.showExactLocationOnMap
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
        guard let listingId = listingViewModel.listing.objectId else { return nil }
        return LetgoURLHelper.buildProductURL(listingId: listingId, isLocalized: true)?.absoluteString
    }
    let sideMargin: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone6) ? Metrics.margin : 0
    var currentAdRequestType: AdRequestType? {
        return adActive ? .dfp : nil
    }
    var adBannerTrackingStatus: AdBannerTrackingStatus? = nil

    convenience init(withVM listingViewModel: ListingCardViewModel,
                     visitSource: EventParameterListingVisitSource) {
        self.init(withVM: listingViewModel,
                  visitSource: visitSource,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsImpressionConfigurable: LGAdsImpressionConfigurable())
    }

    init(withVM listingViewModel: ListingCardViewModel,
         visitSource: EventParameterListingVisitSource,
         featureFlags: FeatureFlaggeable,
         adsImpressionConfigurable: AdsImpressionConfigurable) {
        self.featureFlags = featureFlags
        self.visitSource = visitSource
        self.adsImpressionConfigurable = adsImpressionConfigurable
        self.listingViewModel = listingViewModel
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

    @objc func listingAction() {
        if listingViewModel.isMine {
            listingViewModel.editListing()
        } else {
            listingViewModel.switchFavorite()
        }
    }

    @objc func switchFavorite() {
        listingViewModel.switchFavorite()
    }

    @objc func share() {
        listingViewModel.shareProduct()
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

typealias ListingDetailStats = (views: Int, favs: Int, posted: Date?)
typealias ListingDetailLocation = (location: LGLocationCoordinates2D?, address: String?, showExactLocation: Bool)

extension ListingDetailViewModel: ReactiveCompatible { }

extension Reactive where Base: ListingDetailViewModel {
    var media: Driver<[Media]> { return base.listingViewModel.rx.media }
    var title: Driver<String?> { return base.listingViewModel.rx.productInfo.map { return $0?.title } }
    var price: Driver<String?> { return base.listingViewModel.rx.productInfo.map { return $0?.price } }
    var detail: Driver<String?> { return base.listingViewModel.rx.listing.map { return $0.description }}
    var stats: Driver<ListingDetailStats> {
        let views: Driver<Int>  = base.listingViewModel.rx.listingStats.map { $0?.viewsCount ?? 0 }
        let favs: Driver<Int> = base.listingViewModel.rx.listingStats.map { $0?.favouritesCount ?? 0 }
        let date: Driver<Date?> = base.listingViewModel.rx.productInfo.map { $0?.creationDate }

        return Driver.combineLatest(views, favs, date) { ($0, $1, $2) }
    }
    var user: Driver<UserDetail> {
        let isPro = base.listingViewModel.rx.seller.asDriver(onErrorJustReturn: nil).map { $0?.isProfessional ?? false }
        let userInfo = base.listingViewModel.rx.userInfo

        return Driver.combineLatest(isPro, userInfo) { ($0, $1) }
            .map { (isPro, userInfo) in return UserDetail(userInfo: userInfo, isPro: isPro) }
    }

    var location: Driver<ListingDetailLocation> {
        let productInfoObs = base.listingViewModel.rx.productInfo
        let location = productInfoObs.map { return $0?.location }
        let address = productInfoObs.map { $0?.address }
        let showExactLocation = base.listingViewModel.rx.showExactLocationOnMap
        return Driver.combineLatest(location, address, showExactLocation) { ($0, $1, $2) }

    }

    var action: Driver<ListingAction> {
        let isFavorite = base.listingViewModel.rx.isFavorite
        let isFavoritable = base.listingViewModel.rx.isMine
        let isEditable = base.listingViewModel.rx.status.map { return $0.isEditable }

        return Driver.combineLatest(isFavorite, isFavoritable, isEditable) { ($0, $1, $2) }
            .map { return ListingAction(isFavorite: $0, isFavoritable: $1, isEditable: $2) }
            .distinctUntilChanged()
    }

    var social: Driver<(SocialSharer, SocialMessage?)> {
        return Driver.combineLatest(Driver.just(base.listingViewModel.socialSharer),
                                    base.listingViewModel.rx.socialMessage) { ($0, $1) }
        }
}
