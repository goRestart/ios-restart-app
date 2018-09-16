import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsEnterPayCodeViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
    private let buyer: User
    private let p2pPaymentsRepository: P2PPaymentsRepository
    fileprivate lazy var uiStateRelay = BehaviorRelay<UIState>(value: .enterCode(buyer: self.buyer))

    init(offerId: String,
         buyer: User,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository) {
        self.offerId = offerId
        self.buyer = buyer
        self.p2pPaymentsRepository = p2pPaymentsRepository
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
        }
    }

    private func usePayCode(_ payCode: String) {
        uiStateRelay.accept(.loading(buyer: buyer))
        p2pPaymentsRepository.usePayCode(payCode: payCode, offerId: offerId) { [weak self] result in
            switch result {
            case .success:
                self?.navigator?.close()
            case .failure:
                self?.enterPayCode()
            }
        }
    }

    private func enterPayCode() {
        uiStateRelay.accept(.enterCode(buyer: buyer))
    }
}

// MARK: - UI State

extension P2PPaymentsEnterPayCodeViewModel {
    enum UIState {
        case loading(buyer: User)
        case enterCode(buyer: User)

        var showLoadingIndicator: Bool {
            switch self {
            case .loading: return true
            case .enterCode: return false
            }
        }

        var hideCodeTextField: Bool {
            switch self {
            case .loading: return true
            case .enterCode: return false
            }
        }

        var buyer: User {
            switch self {
            case .loading(buyer: let buyer):
                return buyer
            case .enterCode(buyer: let buyer):
                return buyer
            }
        }

        var descriptionText: String {
            let buyerName = buyer.name ?? ""
            return "Enter the 4-digit code that buyer \(buyerName) has shared with you"
        }
    }
}

// MARK: - UI Actions

extension P2PPaymentsEnterPayCodeViewModel {
    func payCodeEntered(_ payCode: String) {
        usePayCode(payCode)
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsEnterPayCodeViewModel {
    var showLoadingIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showLoadingIndicator } }
    var hideCodeTextField: Driver<Bool> { return uiStateRelay.asDriver().map { $0.hideCodeTextField } }
    var buyerImageURL: Driver<URL?> { return uiStateRelay.asDriver().map { $0.buyer.avatar?.fileURL } }
    var descriptionText: Driver<String> { return uiStateRelay.asDriver().map { $0.descriptionText } }
}
