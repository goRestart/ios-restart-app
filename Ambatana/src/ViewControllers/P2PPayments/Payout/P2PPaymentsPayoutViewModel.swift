import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsPayoutViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository
    private var offer: P2PPaymentOffer?
    private var priceBreakdown: P2PPaymentPayoutPriceBreakdown?
    fileprivate lazy var uiStateRelay = BehaviorRelay<UIState>(value: .loading)

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository,
         myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
        }
    }

    private func fetchOffer() {
        p2pPaymentsRepository.showOffer(id: offerId) { [weak self] result in
            switch result {
            case .success(let offer):
                self?.offer = offer
                self?.fetchPriceBreakdown()
            case .failure:
                // TODO: @juolgon hanlde error case
                break
            }
        }
    }

    private func fetchPriceBreakdown() {
        guard let offer = offer else { return }
        let amount = offer.fees.amount
        let currency = offer.fees.currency
        p2pPaymentsRepository.calculatePayoutPriceBreakdown(amount: amount, currency: currency) { [weak self] result in
            switch result {
            case .success(let priceBreakdown):
                self?.priceBreakdown = priceBreakdown
                self?.checkIfUserNeedsToRegister()
            case .failure:
                // TODO: @juolgon hanlde error case
                break
            }
        }
    }

    private func checkIfUserNeedsToRegister() {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        p2pPaymentsRepository.showSeller(id: userId) { [weak self] result in
            switch result {
            case .success(let seller):
                if seller.hasAcceptedTOS {
                } else {
                    self?.uiStateRelay.accept(.register)
                }
            case .failure:
                // TODO: @juolgon hanlde error case
                break
            }
        }
    }

    private func showPayoutInfo() {
    }
}

// MARK: - UI State

extension P2PPaymentsPayoutViewModel {
    struct PayoutInfo {
        let feeText: String
        let standardFundsAvailableText: String
        let instantFundsAvailableText: String
    }

    enum UIState {
        case loading
        case register
        case payout(info: PayoutInfo)

        var showLoadingIndicator: Bool {
            switch self {
            case .loading: return true
            default: return false
            }
        }

        var registerIsHidden: Bool {
            switch self {
            case .register: return false
            default: return true
            }
        }

        var payoutIsHidden: Bool {
            switch self {
            case .payout: return false
            default: return true
            }
        }
    }
}

// MARK: - UI Actions

extension P2PPaymentsPayoutViewModel {
    func closeButtonPressed() {
        navigator?.close()
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsPayoutViewModel {
    var showLoadingIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showLoadingIndicator } }
    var registerIsHidden: Driver<Bool> { return uiStateRelay.asDriver().map { $0.registerIsHidden } }
    var payoutIsHidden: Driver<Bool> { return uiStateRelay.asDriver().map { $0.payoutIsHidden } }
}
