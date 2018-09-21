import RxSwift
import RxCocoa
import LGCoreKit

struct ChatPaymentBannerViewModel {
    private let offerStateRelay = BehaviorRelay<P2PPaymentState>(value: .offersUnavailable)
    var offerState: Driver<P2PPaymentState> {
        return offerStateRelay.asDriver()
    }
    
    private let isHiddenRelay = BehaviorRelay<Bool>(value: true)
    var isHidden: Driver<Bool> {
        guard featureFlags.makeAnOfferButton.isActive else {
            return Driver<Bool>.just(true)
        }
        return offerState.map { state in
            switch state {
            case .offersUnavailable: return true
            default: return false
            }
        }.asDriver()
    }

    private let actionButtonRelay = PublishRelay<ButtonActionEvent>()
    var buttonAction: Driver<ButtonActionEvent> {
        return actionButtonRelay.asDriver(onErrorJustReturn: .none)
    }
    
    private let p2pRepository: P2PPaymentsRepository
    private let featureFlags: FeatureFlaggeable
    
    init(p2pRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.p2pRepository = p2pRepository
        self.featureFlags = featureFlags
    }
    
    func configure(with params: P2PPaymentStateParams) {
        p2pRepository.getPaymentState(params: params) { result in
            if case let .success(state) = result {
                self.offerStateRelay.accept(state)
            }
        }
    }
    
    func actionButtonWasPressed() {
        switch offerStateRelay.value {
        case .makeOffer:
            actionButtonRelay.accept(.makeOffer)
        case .viewOffer(offerId: let id):
            actionButtonRelay.accept(.viewOffer(offerId: id))
        case .viewPayCode(offerId: let id):
            actionButtonRelay.accept(.viewPayCode(offerId: id))
        case .exchangeCode(offerId: let id):
            actionButtonRelay.accept(.exchangeCode(offerId: id))
        case .payout(offerId: let id):
            actionButtonRelay.accept(.payout(offerId: id))
        case .offersUnavailable:
            break
        }
    }
}
