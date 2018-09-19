import RxCocoa
import LGCoreKit
import LGComponents

struct AppsFlyerKeys {
    static let campaign = "campaign"
    static let firstLaunch = "is_first_launch"
    static let sub1 = "af_sub1"
    static let sub2 = "af_sub2"
    static let sub3 = "af_sub3"
}

final class AppsFlyerAffiliationResolver {
    
    static let shared = AppsFlyerAffiliationResolver()
    static let campaignValue = "affiliate-program"
    
    let rx_referrer = BehaviorRelay<ReferrerInfo?>(value: nil)
    let rx_referredOutsideABTest = BehaviorRelay<Bool>(value: false)
    
    private var data = [AnyHashable : Any]()
    private let myUserRepository: MyUserRepository
    private var isFeatureActive: Bool = false
    
    var isReferral: Bool {
        return rx_referrer.value != nil
    }
    
    init(myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.myUserRepository = myUserRepository
    }
    
    /// Method to be called when Leanplum syncs all the variables
    func activateFeature() {
        isFeatureActive = true
        resolve()
    }
    
    /// Method to be called when the apps flyer data for the affiliation campaign has been received
    func appsFlyerConversionData(data: [AnyHashable : Any]) {
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
        let avatar = data[AppsFlyerKeys.sub3] as? URL
        return ReferrerInfo(userId: userId, name: name, avatar: avatar)
    }

    private func resolve() {
        guard
            isReferralCandidate(),
            myUserRepository.myUser != nil,
            let referrer = referrerInfo()
            else {
                return
        }
        guard isFeatureActive else {
            rx_referredOutsideABTest.accept(true)
            return
        }
        myUserRepository.notifyReferral(inviterId: referrer.userId) { [weak self] result in
            switch result {
            case .success:
                self?.rx_referrer.accept(referrer)
                self?.referralAlreadyNotified()
            case .failure(let error):
                logMessage(.error, type: AppLoggingOptions.deepLink, message: "Failed to notify referral: \(error)")
            }
        }
    }
    
    private func referralAlreadyNotified() {
        // Since this is a singleton, we delete data to avoid notifying the backend more than once if
        // users try to play the system e.g. loging out and in again
        data = [AnyHashable : Any]()
    }
}
