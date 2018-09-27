import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa
import Result

final class P2PPaymentsOfferStatusViewModel: BaseViewModel {
    typealias ActionHandler = () -> Void

    private static let updatesTimeInterval: RxTimeInterval = 10

    private enum Mode {
        case buyer, seller
    }

    var navigator: P2PPaymentsOfferStatusNavigator?
    weak var delegate: BaseViewModelDelegate?
    private let offerId: String
    private var offer: P2PPaymentOffer?
    private var listing: Listing?
    private var buyer: User?
    private var mode: Mode?
    private var isAutoUpdating: Bool = false
    private var updateTimerDisposable: Disposable?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let listingRepository: ListingRepository
    private let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let installationRepository: InstallationRepository
    private let tracker: Tracker
    private let stateRelay = BehaviorRelay<UIState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository,
         listingRepository: ListingRepository = Core.listingRepository,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         userRepository: UserRepository = Core.userRepository,
         installationRepository: InstallationRepository = Core.installationRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.listingRepository = listingRepository
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.installationRepository = installationRepository
        self.tracker = tracker
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        getP2PPaymentsOffer()
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        stopAutoUpdates()
    }

    private func getP2PPaymentsOffer() {
        if !isAutoUpdating {
            stateRelay.accept(.loading)
        }
        p2pPaymentsRepository.showOffer(id: offerId) { [weak self] result in
            switch result {
            case .success(let offer):
                self?.offer = offer
                self?.getListingInformation()
            case .failure:
                guard let autoupdating = self?.isAutoUpdating else { return }
                if !autoupdating {
                    self?.stateRelay.accept(.errorRetry)
                }
            }
        }
    }

    private func getListingInformation() {
        guard let listingId = offer?.listingId else { return }
        listingRepository.retrieve(listingId) { [weak self] result in
            switch result {
            case .success(let listing):
                self?.listing = listing
                self?.getBuyerInformationIfNeeded()
            case .failure:
                guard let autoupdating = self?.isAutoUpdating else { return }
                if !autoupdating {
                    self?.stateRelay.accept(.errorRetry)
                }
            }
        }
    }

    private func getBuyerInformationIfNeeded() {
        configureMode()
        guard let mode = mode else { return }
        if mode == .seller {
            getBuyerInformation()
        } else {
            updateState()
        }
    }

    private func configureMode() {
        guard let buyerId = offer?.buyerId,
            let sellerId = offer?.sellerId,
            let myUserId = myUserRepository.myUser?.objectId else { return }
        if myUserId == buyerId {
            mode = .buyer
        }
        if myUserId == sellerId {
            mode = .seller
        }
    }

    private func getBuyerInformation() {
        guard let buyerId = offer?.buyerId else { return }
        userRepository.show(buyerId) { [weak self] result in
            switch result {
            case .success(let buyer):
                self?.buyer = buyer
                self?.updateState()
            case .failure:
                guard let autoupdating = self?.isAutoUpdating else { return }
                if !autoupdating {
                    self?.stateRelay.accept(.errorRetry)
                }
            }
        }
    }

    private func updateState() {
        guard let offer = offer, let mode = mode else {
            stateRelay.accept(.loading)
            return
        }
        switch mode {
        case .buyer:
            guard let listing = listing else {
                stateRelay.accept(.loading)
                return
            }
            stateRelay.accept(.buyerInfoLoaded(offer: offer, listing: listing))
        case .seller:
            guard let listing = listing, let buyer = buyer else {
                stateRelay.accept(.loading)
                return
            }
            trackSellerOfferDetail()
            stateRelay.accept(.sellerInfoLoaded(offer: offer, listing: listing, buyer: buyer))
        }
        startAutoUpdatesIfNeeded()
    }

    private func startAutoUpdatesIfNeeded() {
        guard updateTimerDisposable == nil else { return }
        isAutoUpdating = true
        let timer = Observable<Int>.timer(P2PPaymentsOfferStatusViewModel.updatesTimeInterval,
                                          period: P2PPaymentsOfferStatusViewModel.updatesTimeInterval,
                                          scheduler: MainScheduler.instance)
        updateTimerDisposable = timer.subscribe(onNext: { [weak self] _ in
            self?.getP2PPaymentsOffer()
        })
        updateTimerDisposable?.disposed(by: disposeBag)
    }

    private func stopAutoUpdates() {
        isAutoUpdating = false
        updateTimerDisposable?.dispose()
        updateTimerDisposable = nil
    }

    private func withdrawOffer() {
        trackOfferWithdraw()
        delegate?.vmShowLoading(nil)
        p2pPaymentsRepository.changeOfferStatus(offerId: offerId, status: .canceled) { [weak self] result in
            self?.handleResult(result)
        }
    }

    private func declineOffer() {
        trackSellerOfferDecline()
        delegate?.vmShowLoading(nil)
        p2pPaymentsRepository.changeOfferStatus(offerId: offerId, status: .declined) { [weak self] result in
            self?.handleResult(result)
        }
    }

    private func acceptOffer() {
        trackSellerOfferAccept()
        delegate?.vmShowLoading(nil)
        p2pPaymentsRepository.changeOfferStatus(offerId: offerId, status: .accepted) { [weak self] result in
            self?.handleResult(result)
        }
    }

    private func handleResult<T>(_ result: Result<T, RepositoryError>) {
        switch result {
        case .success:
            delay(P2PPayments.chatRefreshDelay) { [weak self] in
                self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                self?.getP2PPaymentsOffer()
            }
        case .failure:
            delegate?.vmHideLoading(R.Strings.paymentsLoadingGenericError, afterMessageCompletion: nil)
        }
    }

    // MARK: Tracking

    private func trackOfferWithdraw() {
        guard let offer = offer, let listing = listing else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferStatusWithdraw(offer: offer, listing: listing)
        tracker.trackEvent(trackerEvent)
    }

    private func trackCodeView() {
        guard let offer = offer, let listing = listing else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferStatusViewCode(offer: offer, listing: listing)
        tracker.trackEvent(trackerEvent)
    }

    private func trackSellerOfferDetail() {
        guard let offer = offer, let listing = listing else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferStatusSeller(offer: offer, listing: listing)
        tracker.trackEvent(trackerEvent)
    }

    private func trackSellerOfferAccept() {
        guard let offer = offer, let listing = listing else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferStatusSellerAccept(offer: offer, listing: listing)
        tracker.trackEvent(trackerEvent)
    }

    private func trackSellerOfferDecline() {
        guard let offer = offer, let listing = listing else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferStatusSellerDecline(offer: offer, listing: listing)
        tracker.trackEvent(trackerEvent)
    }

    private func trackSellerOfferEnterCode() {
        guard let offer = offer, let listing = listing else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferStatusSellerEnterCode(offer: offer, listing: listing)
        tracker.trackEvent(trackerEvent)
    }
}

// MARK: - UI Actions

extension P2PPaymentsOfferStatusViewModel {
    func closeButtonPressed() {
        navigator?.close()
    }

    func actionButtonPressed() {
        guard let offer = offer else { return }
        switch offer.status {
        case .accepted:
            trackCodeView()
            navigator?.openGetPayCode()
        default:
            navigator?.close()
        }
    }

    func withdrawnButtonPressed() {
        withdrawOffer()
    }

    func declineButtonPressed() {
        declineOffer()
    }

    func acceptButtonPressed() {
        acceptOffer()
    }

    func enterCodeButtonPressed() {
        guard let buyer = buyer else { return }
        trackSellerOfferEnterCode()
        navigator?.openEnterPayCode(buyer: buyer)
    }

    func retryButtonPressed() {
        getP2PPaymentsOffer()
    }

    func contactUsActionSelected() {
        guard let email = myUserRepository.myUser?.email,
            let installation = installationRepository.installation,
            let url = LetgoURLHelper.buildContactUsURL(userEmail: email, installation: installation,
                                                       listing: nil, type: .payment) else { return }
        navigator?.openContactUs(url: url)
    }

    func faqsActionSelected() {
        guard let url = LetgoURLHelper.buildPaymentFaqsURL() else { return }
        navigator?.openFaqs(url: url)
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsOfferStatusViewModel {
    var showLoadingIndicator: Driver<Bool> { return stateRelay.asDriver().map { $0.showLoadingIndicator } }
    var hideBuyerInfo: Driver<Bool> { return stateRelay.asDriver().map { $0.hideBuyerInfo } }
    var hideSellerInfo: Driver<Bool> { return stateRelay.asDriver().map { $0.hideSellerInfo } }
    var hideErrorRetry: Driver<Bool> { return stateRelay.asDriver().map { $0.hideErrorRetry } }

    var listingTitle: Driver<String?> { return stateRelay.asDriver().map { $0.listingTitle } }
    var listingImageURL: Driver<URL?> { return stateRelay.asDriver().map { $0.listingImageURL } }
    var actionButtonTitle: Driver<String?> { return stateRelay.asDriver().map { $0.actionButtonTitle } }
    var buyerStepList: Driver<P2PPaymentsOfferStatusStepListState?> {
        return stateRelay.asDriver().map { [weak self] state in
            state.buyerStepList(actionHandler: { self?.withdrawnButtonPressed() })
        }
    }

    var sellerHeaderImageURL: Driver<URL?> { return stateRelay.asDriver().map { $0.sellerHeaderImageURL } }
    var sellerHeaderTitle: Driver<String?> { return stateRelay.asDriver().map { $0.sellerHeaderTitle } }
    var netAmountText: Driver<String?> { return stateRelay.asDriver().map { $0.netAmountText } }
    var feeAmountText: Driver<String?> { return stateRelay.asDriver().map { $0.feeAmountText } }
    var grossAmountText: Driver<String?> { return stateRelay.asDriver().map { $0.grossAmountText } }
    var feePercentageText: Driver<String?> { return stateRelay.asDriver().map { $0.feePercentageText } }
    var declineButtonIsHidden: Driver<Bool> { return stateRelay.asDriver().map { $0.declineButtonIsHidden } }
    var acceptButtonIsHidden: Driver<Bool> { return stateRelay.asDriver().map { $0.acceptButtonIsHidden } }
    var enterCodeButtonIsHidden: Driver<Bool> { return stateRelay.asDriver().map { $0.enterCodeButtonIsHidden } }
    var sellerStepList: Driver<P2PPaymentsOfferStatusStepListState?> { return stateRelay.asDriver().map { $0.sellerStepList } }
}
