import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsEnterPayCodeViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
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
        }
    }
}

// MARK: - UI State

extension P2PPaymentsEnterPayCodeViewModel {
    enum UIState {
        case loading
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsGetPayCodeViewModel {
}
