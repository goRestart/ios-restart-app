import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsOfferStatusViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusNavigator?
    private let offerId: String
    private var offer: P2PPaymentOffer?
    private var listing: Listing?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let listingRepository: ListingRepository
    private let myUserRepository: MyUserRepository

    private let listingImageViewURLRelay = BehaviorRelay<URL?>(value: nil)
    private let listingTitleRelay = BehaviorRelay<String?>(value: nil)

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

    private func setup() {
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
            case .failure:
                // TODO: @juolgon properly handle error here
                self?.getListingInformation() // Fail silently and retry
            }
        }
    }
}

// MARK: - UI Actions

extension P2PPaymentsOfferStatusViewModel {
    func closeButtonPressed() {
        navigator?.close()
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsOfferStatusViewModel {
    var listingImageViewURL: Driver<URL?> { return listingImageViewURLRelay.asDriver() }
    var listingTitle: Driver<String?> { return listingTitleRelay.asDriver() }
}
