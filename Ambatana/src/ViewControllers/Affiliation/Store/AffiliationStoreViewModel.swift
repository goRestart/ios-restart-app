import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa
// This should be in Core 🖲
enum AffiliationPartner {
    case amazon
}

struct AffiliationPurchase {
    enum State {
        case enabled, disabled
    }

    let title: String
    let partnerIcon: UIImage
    let points: String

    let state: State
}

final class AffiliationStoreViewModel: BaseViewModel {
    fileprivate let state: PublishSubject<ViewState> = .init()
    var navigator: AffiliationStoreNavigator?
    private(set) var purchases: [AffiliationPurchase] = []
    var moreActions: [UIAction] {
        return [UIAction(interface: .text(R.Strings.affiliationStoreHistory),
                         action: { [weak self] in self?.openHistory() })]
    }
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        reloadPurchases()
    }

    private func reloadPurchases() {
        state.onNext(.loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.purchases = AffiliationStoreViewModel.mockPurchases()
            self?.state.onNext(.data)
        }
    }

    private func openHistory() {
        navigator?.openHistory()
    }
}

private extension AffiliationStoreViewModel {
    static func mockPurchases() -> [AffiliationPurchase] {
        // TODO: Delete when core side is done
        return [
            AffiliationPurchase(title: "$10 Amazon Gift Card",
                                partnerIcon: R.Asset.Affiliation.Partners.amazon.image,
                                points: "10 points",
                                state: .enabled),
            AffiliationPurchase(title: "$30 Amazon Gift Card",
                                partnerIcon: R.Asset.Affiliation.Partners.amazon.image,
                                points: "30 points",
                                state: .enabled),
            AffiliationPurchase(title: "$50 Amazon Gift Card",
                                partnerIcon: R.Asset.Affiliation.Partners.amazon.image,
                                points: "50 points",
                                state: .disabled),
        ]
    }
}

extension AffiliationStoreViewModel: ReactiveCompatible {}
extension Reactive where Base: AffiliationStoreViewModel {
    var state: Driver<ViewState> {
        return base.state.asDriver(onErrorJustReturn: .error(LGEmptyViewModel.map(from: RepositoryError.userNotVerified,
                                                                                  action: nil)!)) // TODO: Fail with style
    }
}

