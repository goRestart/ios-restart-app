import RxSwift
import RxCocoa
import LGCoreKit

final class ChatPaymentBannerViewModel {
    private static let updatesTimeInterval: RxTimeInterval = 10

    private let offerStateRelay = BehaviorRelay<P2PPaymentState>(value: .offersUnavailable)
    var offerState: Driver<P2PPaymentState> {
        return offerStateRelay.asDriver()
    }
    
    private let isHiddenRelay = BehaviorRelay<Bool>(value: true)
    private var params: P2PPaymentStateParams?
    private var disposeBag = DisposeBag()
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
        self.params = params
        startAutoUpdates()
    }

    private func startAutoUpdates() {
        disposeBag = DisposeBag()
        let timer = Observable<Int>.timer(0,
                                          period: ChatPaymentBannerViewModel.updatesTimeInterval,
                                          scheduler: MainScheduler.instance)
        timer.subscribe(onNext: { [weak self] _ in
            self?.updateState()
        }).disposed(by: disposeBag)
    }

    private func updateState() {
        guard let params = params else { return }
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
