import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsEnterPayCodeViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
    private let buyerName: String
    private let buyerAvatar: File?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    fileprivate lazy var uiStateRelay = BehaviorRelay<UIState>(value: .enterCode(buyerName: buyerName, buyerAvatar: buyerAvatar))

    init(offerId: String,
         buyerName: String,
         buyerAvatar: File?,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository) {
        self.offerId = offerId
        self.buyerName = buyerName
        self.buyerAvatar = buyerAvatar
        self.p2pPaymentsRepository = p2pPaymentsRepository
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
        }
    }

    private func usePayCode(_ payCode: String) {
        uiStateRelay.accept(.loading(buyerName: buyerName, buyerAvatar: buyerAvatar))
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
        uiStateRelay.accept(.enterCode(buyerName: buyerName, buyerAvatar: buyerAvatar))
    }
}

// MARK: - UI State

extension P2PPaymentsEnterPayCodeViewModel {
    enum UIState {
        case loading(buyerName: String, buyerAvatar: File?)
        case enterCode(buyerName: String, buyerAvatar: File?)

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

        var buyerName: String {
            switch self {
            case .loading(buyerName: let name, buyerAvatar: _), .enterCode(buyerName: let name, buyerAvatar: _):
                return name
            }
        }

        var buyerAvatar: File? {
            switch self {
            case .loading(buyerName: _, buyerAvatar: let buyerAvatar):
                return buyerAvatar
            case .enterCode(buyerName: _, buyerAvatar: let buyerAvatar):
                return buyerAvatar
            }
        }

        var descriptionText: String {
            return "Enter the 4-digit code that buyer \(buyerName) has shared with you"
        }
    }
}

// MARK: - UI Actions

extension P2PPaymentsEnterPayCodeViewModel {
    func payCodeEntered(_ payCode: String) {
        usePayCode(payCode)
    }

    func closeButtonPressed() {
        navigator?.close()
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsEnterPayCodeViewModel {
    var showLoadingIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showLoadingIndicator } }
    var hideCodeTextField: Driver<Bool> { return uiStateRelay.asDriver().map { $0.hideCodeTextField } }
    var buyerImageURL: Driver<URL?> { return uiStateRelay.asDriver().map { $0.buyerAvatar?.fileURL } }
    var descriptionText: Driver<String> { return uiStateRelay.asDriver().map { $0.descriptionText } }
}
