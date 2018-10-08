import RxCocoa
import RxSwift
import LGCoreKit
import LGComponents

struct AppsFlyerKeys {
    static let campaign = "campaign"
    static let firstLaunch = "is_first_launch"
    static let sub1 = "af_sub1"
    static let sub2 = "af_sub2"
    static let sub3 = "af_sub3"
}

enum AffiliationCampaignState {
    case unknown
    case campaignNotAvailableForUser
    case referral(referrer: ReferrerInfo)
}

extension AffiliationCampaignState: Equatable {
    static func == (lhs: AffiliationCampaignState, rhs: AffiliationCampaignState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.campaignNotAvailableForUser, .campaignNotAvailableForUser):
            return true
        case (.referral(let lhsReferrer), .referral(let rhsReferrer)):
            return lhsReferrer == rhsReferrer
        case (.unknown, _), (_, .unknown), (.campaignNotAvailableForUser, _), (_, .campaignNotAvailableForUser):
            return false
        }
    }
}

final class AppsFlyerAffiliationResolver {
    
    static let shared = AppsFlyerAffiliationResolver()
    static let campaignValue = "affiliate-program"

    /// This var should not be used outside. Set it internal and fix tests (talk to Xavi)
    let rx_affiliationCampaign = BehaviorRelay<AffiliationCampaignState>(value: .unknown)
    let rx_AppIsReady = BehaviorRelay<Bool>(value: false)

    private var data = [AnyHashable : Any]()
    private let myUserRepository: MyUserRepository
    private var isFeatureActive: Bool = false
    private var isFeatureStatusNotified: Bool = false
    private var waitingBouncerConfirmation: Bool  = false

    /// Either it is a referral or we are waiting for Bouncer confirmation
    var isProbablyReferral: Bool {
        if case AffiliationCampaignState.referral = rx_affiliationCampaign.value {
            return true
        }
        return waitingBouncerConfirmation
    }
    
    init(myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.myUserRepository = myUserRepository
    }
    
    /// Method to be called when Leanplum syncs all the variables
    func setCampaignFeatureAs(active: Bool) {
        isFeatureStatusNotified = true
        isFeatureActive = active
        resolve()
    }
    
    /// Method to be called when the apps flyer data for the affiliation campaign has been received
    func appsFlyerConversionData(data: [AnyHashable : Any]) {
        guard self.data.isEmpty else { return }
        self.data = data
        resolve()
    }

    /// Method to be called right after the user authenticates
    func userLoggedIn() {
        resolve()
    }
}

private extension AppsFlyerAffiliationResolver {

    private func isReferralCandidate() -> Bool {
        guard
            let campaign = data[AppsFlyerKeys.campaign] as? String, campaign == AppsFlyerAffiliationResolver.campaignValue,
            let firstLaunch = data[AppsFlyerKeys.firstLaunch] as? Bool, firstLaunch
            else {
                return false
        }
        return true
    }
    
    private func referrerInfo() -> ReferrerInfo? {
        guard let userId = data[AppsFlyerKeys.sub1] as? String else {
            return nil
        }
        let name = data[AppsFlyerKeys.sub2] as? String ?? ""
        let avatar: URL?
        if let avatarString = data[AppsFlyerKeys.sub3] as? String {
            avatar = URL(string: avatarString)
        } else {
            avatar = nil
        }
        return ReferrerInfo(userId: userId, name: name, avatar: avatar)
    }

    private func resolve() {
        guard isReferralCandidate() else { return }
        guard
            myUserRepository.myUser != nil,
            let referrer = referrerInfo(),
            isFeatureStatusNotified
            else {
                rx_affiliationCampaign.accept(.unknown)
                return
        }
        guard isFeatureActive else {
            rx_affiliationCampaign.accept(.campaignNotAvailableForUser)
            return
        }
        waitingBouncerConfirmation = true
        myUserRepository.notifyReferral(inviterId: referrer.userId) { [weak self] result in
            switch result {
            case .success:
                self?.rx_affiliationCampaign.accept(.referral(referrer: referrer))
            case .failure(let error):
                logMessage(.error, type: AppLoggingOptions.deepLink, message: "Failed to notify referral: \(error)")
            }
            self?.waitingBouncerConfirmation = false
        }
    }
}

extension AppsFlyerAffiliationResolver: ReactiveCompatible {}
extension Reactive where Base: AppsFlyerAffiliationResolver {
    var affiliationCampaign: Observable<AffiliationCampaignState> {
        return Observable.combineLatest(base.rx_affiliationCampaign.asObservable(),
                                        base.rx_AppIsReady.asObservable())
            .filter({ (referrer, ready) -> Bool in return ready }) // we filter until the app is ready
            .map { $0.0 }
    }
}
