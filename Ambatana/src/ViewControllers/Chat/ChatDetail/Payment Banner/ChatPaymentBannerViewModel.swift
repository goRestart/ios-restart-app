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
    
    init(p2pRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository) {
        self.p2pRepository = p2pRepository
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
        case .viewOffer:
            actionButtonRelay.accept(.viewOffer)
        case .viewPayCode:
            actionButtonRelay.accept(.viewPayCode)
        case .exchangeCode:
            actionButtonRelay.accept(.exchangeCode)
        case .payout:
            actionButtonRelay.accept(.payout)
        case .offersUnavailable:
            break
        }
    }
}
