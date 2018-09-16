import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsPayoutViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
    private let p2pPaymentsRepository: P2PPaymentsRepository

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository) {
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

// MARK: - UI Actions

extension P2PPaymentsPayoutViewModel {
    func closeButtonPressed() {
        navigator?.close()
    }
}
