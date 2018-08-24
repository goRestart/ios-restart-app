import Foundation
import LGCoreKit

protocol ProfessionalDealerAskPhoneAssembly {
    func buildProfessionalDealerAskPhone(listing: Listing, interlocutor: User?) -> UIViewController
}

enum ProfessionalDealerAskPhoneBuilder {
    case standard(UINavigationController)
    case modal(UIViewController)
}

extension ProfessionalDealerAskPhoneBuilder: ProfessionalDealerAskPhoneAssembly {
    func buildProfessionalDealerAskPhone(listing: Listing, interlocutor: User?) -> UIViewController {
        let vm = ProfessionalDealerAskPhoneViewModel(listing: listing,
                                                           interlocutor: interlocutor,
                                                           typePage: .listingDetail)
        let vc = ProfessionalDealerAskPhoneViewController(viewModel: vm)

        switch self {
        case .modal(let root):
            let nav = UINavigationController(rootViewController: vc)
            vc.setupForModalWithNonOpaqueBackground()
            vm.navigator = ProfessionalDealerAskPhoneModalWireframe(root: root, nc: nav)
            return nav
        case .standard(let nav):
            vc.setupForModalWithNonOpaqueBackground()
            vm.navigator = ProfessionalDealerAskPhoneModalWireframe(root: nav, nc: nav)
            return vc
        }
    }
}
