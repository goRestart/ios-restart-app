import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsGetPayCodeViewModel: BaseViewModel {
    private static let retryInterval: TimeInterval = 5

    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
    private var payCode: String?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let uiStateRelay = BehaviorRelay<UIState>(value: .loading)

    convenience init(offerId: String) {
        self.init(offerId: offerId,
                  p2pPaymentsRepository: Core.p2pPaymentsRepository)
    }

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            getPayCode()
        }
    }

    private func getPayCode() {
        p2pPaymentsRepository.getPayCode(offerId: offerId) { [weak self] result in
            switch result {
            case .success(let payCode):
                self?.payCode = payCode
                self?.updateUIState()
            case .failure:
                // Fail silently and retry after N seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + P2PPaymentsGetPayCodeViewModel.retryInterval) {
                    self?.getPayCode()
                }
            }
        }
    }

    private func updateUIState() {
        guard let payCode = payCode else {
            uiStateRelay.accept(.loading)
            return
        }
        uiStateRelay.accept(.payCodeLoaded(payCode))
    }
}

// MARK: - UI State

extension P2PPaymentsGetPayCodeViewModel {
    enum UIState {
        case loading
        case payCodeLoaded(String)

        var showActivityIndicator: Bool {
            switch self {
            case .loading: return true
            case .payCodeLoaded: return false
            }
        }

        var payCode: String? {
            switch self {
            case .loading: return nil
            case .payCodeLoaded(let payCode): return payCode
            }
        }
    }
}

// MARK: - UI Actions

extension P2PPaymentsGetPayCodeViewModel {
    func closeButtonPressed() {
        navigator?.close()
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsGetPayCodeViewModel {
    var showActivityIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showActivityIndicator } }
    var payCodeText: Driver<String?> { return uiStateRelay.asDriver().map { $0.payCode } }
}
