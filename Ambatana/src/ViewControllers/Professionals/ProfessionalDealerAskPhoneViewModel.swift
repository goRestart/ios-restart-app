import Foundation
import LGCoreKit
import RxSwift
import LGComponents

class ProfessionalDealerAskPhoneViewModel: BaseViewModel {

    private let phoneNumber = Variable<String>("")
    let sendPhoneButtonEnabled = Variable<Bool>(false)
    private let disposeBag = DisposeBag()

    weak var navigator: ListingDetailNavigator?
    private let listing: Listing
    private let interlocutor: User?
    private let tracker: Tracker
    private let typePage: EventParameterTypePage

    convenience init(listing: Listing, interlocutor: User?, typePage: EventParameterTypePage) {
        self.init(listing: listing, interlocutor: interlocutor, tracker: TrackerProxy.sharedInstance, typePage: typePage)
    }

    init(listing: Listing, interlocutor: User?, tracker: Tracker, typePage: EventParameterTypePage) {
        self.listing = listing
        self.interlocutor = interlocutor
        self.tracker = tracker
        self.typePage = typePage
        super.init()
        setupRx()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        tracker.trackEvent(TrackerEvent.phoneNumberRequest(typePage: typePage))
    }

    func setupRx() {
        phoneNumber.asObservable()
            .map { $0.isPhoneNumber }
            .bind(to: sendPhoneButtonEnabled)
            .disposed(by: disposeBag)
    }

    func updatePhoneNumberFrom(text: String) {
        let noDashesText = text.replacingOccurrences(of: "-", with: "")
        phoneNumber.value = noDashesText
    }
    
    func sendPhonePressed() {
        navigator?.closeAskPhoneFor(listing: listing,
                                    openChat: true,
                                    withPhoneNum: phoneNumber.value,
                                    source: typePage,
                                    interlocutor: interlocutor)
        tracker.trackEvent(TrackerEvent.phoneNumberSent(typePage: typePage))
    }

    func closePressed() {
        navigator?.closeAskPhoneFor(listing: listing,
                                    openChat: false,
                                    withPhoneNum: nil,
                                    source: typePage,
                                    interlocutor: interlocutor)
    }

    func notNowPressed() {
        navigator?.closeAskPhoneFor(listing: listing,
                                    openChat: true,
                                    withPhoneNum: nil,
                                    source: typePage,
                                    interlocutor: interlocutor)
        tracker.trackEvent(TrackerEvent.phoneNumberNotNow(typePage: typePage))
    }
}
