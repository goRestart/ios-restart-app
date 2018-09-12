import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsOfferStatusViewModel: BaseViewModel {
    typealias ActionHandler = () -> Void

    var navigator: P2PPaymentsOfferStatusNavigator?
    private let offerId: String
    private var offer: P2PPaymentOffer?
    private var listing: Listing?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let listingRepository: ListingRepository
    private let myUserRepository: MyUserRepository

    private let stateRelay = BehaviorRelay<UIState>(value: .loading)

    convenience init(offerId: String) {
        self.init(offerId: offerId,
                  p2pPaymentsRepository: Core.p2pPaymentsRepository,
                  listingRepository: Core.listingRepository,
                  myUserRepository: Core.myUserRepository)
    }

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository,
         listingRepository: ListingRepository,
         myUserRepository: MyUserRepository) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.listingRepository = listingRepository
        self.myUserRepository = myUserRepository
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            getP2PPaymentsOffer()
        }
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
                self?.updateState()
            case .failure:
                // TODO: @juolgon properly handle error here
                self?.getListingInformation() // Fail silently and retry
            }
        }
    }

    private func updateState() {
        guard let offer = offer, let listing = listing else {
            stateRelay.accept(.loading)
            return
        }
        stateRelay.accept(.buyerInfoLoaded(offer: offer, listing: listing))
    }

    private func withdrawOffer() {
        stateRelay.accept(.loading)
        p2pPaymentsRepository.changeOfferStatus(offerId: offerId, status: .canceled) { [weak self] _ in
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
        navigator?.close()
    }

    func withdrawnButtonPressed() {
        withdrawOffer()
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsOfferStatusViewModel {
    var showLoadingIndicator: Driver<Bool> { return stateRelay.asDriver().map { $0.showLoadingIndicator } }
    var listingTitle: Driver<String?> { return stateRelay.asDriver().map { $0.listingTitle } }
    var listingImageURL: Driver<URL?> { return stateRelay.asDriver().map { $0.listingImageURL } }
    var actionButtonTitle: Driver<String?> { return stateRelay.asDriver().map { $0.actionButtonTitle } }
    var stepList: Driver<P2PPaymentsOfferStatusStepListState?> {
        return stateRelay.asDriver().map { [weak self] state in
            state.stepList(actionHandler: { self?.withdrawnButtonPressed() })
        }
    }
}
