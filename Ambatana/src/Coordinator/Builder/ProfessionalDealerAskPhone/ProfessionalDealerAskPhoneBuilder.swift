import Foundation
import LGCoreKit

protocol ProfessionalDealerAskPhoneAssembly {
    func buildProfessionalDealerAskPhone(listing: Listing,
                                         interlocutor: User?,
                                         chatNavigator: ChatNavigator) -> UIViewController
}

enum ProfessionalDealerAskPhoneBuilder {
    case modal(UIViewController)
}

extension ProfessionalDealerAskPhoneBuilder: ProfessionalDealerAskPhoneAssembly {
    func buildProfessionalDealerAskPhone(listing: Listing,
                                         interlocutor: User?,
                                         chatNavigator: ChatNavigator) -> UIViewController {
        let vm = ProfessionalDealerAskPhoneViewModel(listing: listing,
                                                     interlocutor: interlocutor,
                                                     typePage: .listingDetail)
        let vc = ProfessionalDealerAskPhoneViewController(viewModel: vm)

        switch self {
        case .modal(let root):
            vc.setupForModalWithNonOpaqueBackground()
            vm.navigator = ProfessionalDealerAskPhoneModalWireframe(root: root, chatNavigator: chatNavigator)
            return vc
        }
    }
}
