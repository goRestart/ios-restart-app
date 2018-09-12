import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsOfferStatusViewModel: BaseViewModel {
    typealias ActionHandler = () -> Void

    private static let updatesTimeInterval: RxTimeInterval = 10

    private enum Mode {
        case buyer, seller
    }

    var navigator: P2PPaymentsOfferStatusNavigator?
    private let offerId: String
    private var offer: P2PPaymentOffer?
    private var listing: Listing?
    private var buyer: User?
    private var mode: Mode?
    private var updateTimerDisposable: Disposable?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let listingRepository: ListingRepository
    private let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let stateRelay = BehaviorRelay<UIState>(value: .loading)
    private let disposeBag = DisposeBag()

    convenience init(offerId: String) {
        self.init(offerId: offerId,
                  p2pPaymentsRepository: Core.p2pPaymentsRepository,
                  listingRepository: Core.listingRepository,
                  myUserRepository: Core.myUserRepository,
                  userRepository: Core.userRepository)
    }

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository,
         listingRepository: ListingRepository,
         myUserRepository: MyUserRepository,
         userRepository: UserRepository) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.listingRepository = listingRepository
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
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
        p2pPaymentsRepository.showOffer(id: offerId) { [weak self] result in
            switch result {
            case .success(let offer):
                self?.offer = offer
                self?.getListingInformation()
            case .failure:
                // TODO: @juolgon properly handle error here
                self?.getP2PPaymentsOffer() // Fail silently and retry
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
                // TODO: @juolgon properly handle error here
                self?.getListingInformation() // Fail silently and retry
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
                // TODO: @juolgon properly handle error here
                self?.getBuyerInformation() // Fail silently and retry
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
            stateRelay.accept(.sellerInfoLoaded(offer: offer, listing: listing, buyer: buyer))
        }
        startAutoUpdatesIfNeeded()
    }

    private func startAutoUpdatesIfNeeded() {
        guard updateTimerDisposable == nil else { return }
        let timer = Observable<Int>.timer(P2PPaymentsOfferStatusViewModel.updatesTimeInterval,
                                          period: P2PPaymentsOfferStatusViewModel.updatesTimeInterval,
                                          scheduler: MainScheduler.instance)
        updateTimerDisposable = timer.subscribe(onNext: { [weak self] _ in
            self?.getP2PPaymentsOffer()
        })
        updateTimerDisposable?.disposed(by: disposeBag)
    }

    private func stopAutoUpdates() {
        updateTimerDisposable?.dispose()
        updateTimerDisposable = nil
    }

    private func withdrawOffer() {
        stateRelay.accept(.loading)
        p2pPaymentsRepository.changeOfferStatus(offerId: offerId, status: .canceled) { [weak self] _ in
            // TODO: @juolgon properly handle error here
            self?.getP2PPaymentsOffer()
        }
    }

    private func declineOffer() {
        stateRelay.accept(.loading)
        p2pPaymentsRepository.changeOfferStatus(offerId: offerId, status: .declined) { [weak self] _ in
            // TODO: @juolgon properly handle error here
            self?.getP2PPaymentsOffer()
        }
    }

    private func acceptOffer() {
        stateRelay.accept(.loading)
        p2pPaymentsRepository.changeOfferStatus(offerId: offerId, status: .accepted) { [weak self] _ in
            // TODO: @juolgon properly handle error here
            self?.getP2PPaymentsOffer()
        }
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
        navigator?.openEnterPayCode()
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsOfferStatusViewModel {
    var showLoadingIndicator: Driver<Bool> { return stateRelay.asDriver().map { $0.showLoadingIndicator } }
    var hideBuyerInfo: Driver<Bool> { return stateRelay.asDriver().map { $0.hideBuyerInfo } }
    var hideSellerInfo: Driver<Bool> { return stateRelay.asDriver().map { $0.hideSellerInfo } }

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
