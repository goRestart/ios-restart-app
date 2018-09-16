import Foundation
import LGCoreKit

protocol P2PPaymentsOfferStatusNavigator {
    func close()
    func openGetPayCode()
    func openEnterPayCode(buyer: User)
}

final class P2PPaymentsOfferStatusWireframe: P2PPaymentsOfferStatusNavigator {
    private let offerId: String
    private weak var navigationController: UINavigationController?

    init(offerId: String,
         navigationController: UINavigationController) {
        self.offerId = offerId
        self.navigationController = navigationController
    }

    func close() {
        navigationController?.dismiss(animated: true)
    }

    func openGetPayCode() {
        guard let nc = navigationController else { return }
        let vc = P2PPaymentsOfferStatusBuilder.standard(nc: nc).buildGetPayCode(offerId: offerId)
        nc.pushViewController(vc, animated: true)
    }

    func openEnterPayCode(buyer: User) {
        guard let nc = navigationController else { return }
        let vc = P2PPaymentsOfferStatusBuilder.standard(nc: nc).buildEnterPayCode(offerId: offerId,
                                                                                  buyerName: buyer.name ?? "",
                                                                                  buyerAvatar: buyer.avatar)
        nc.pushViewController(vc, animated: true)
    }
}
