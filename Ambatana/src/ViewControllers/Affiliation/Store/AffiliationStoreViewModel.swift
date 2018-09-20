import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa
import Result

enum AffiliationPartner {
    case amazon
    var image: UIImage { return R.Asset.Affiliation.Partners.amazon.image }
}

struct AffiliationPurchase {
    enum State {
        case enabled, disabled
    }
    
    let title: String
    let partnerIcon: UIImage
    let points: Int
    
    let state: State
}

final class AffiliationStoreViewModel: BaseViewModel {
    let cellRedeemTapped = PublishRelay<Int>()
    fileprivate let viewState = BehaviorRelay<ViewState>(value: .loading)
    fileprivate let pointsRelay = BehaviorRelay<Int>(value: 0)
    private let disposeBag = DisposeBag()
    
    fileprivate let myUserRepository: MyUserRepository
    private let rewardsRepository: RewardRepository
    private let locationManager: LocationManager
    
    var navigator: AffiliationStoreNavigator?
    
    private(set) var rewards: [Reward] = []
    private(set) var purchases: [AffiliationPurchase] = []
    
    var moreActions: [UIAction] {
        return [UIAction(interface: .text(R.Strings.affiliationStoreHistory), action: openHistory)]
    }
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  rewardsRepository: Core.rewardRepository,
                  locationManager: Core.locationManager)
    }
    
    init(myUserRepository: MyUserRepository,
         rewardsRepository: RewardRepository,
         locationManager: LocationManager) {
        self.myUserRepository = myUserRepository
        self.rewardsRepository = rewardsRepository
        self.locationManager = locationManager
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            reloadAll()
        }
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationStore()
        return true
    }
    
    private func reloadAll() {
        let points = retrieveAffiliationPoints().asObservable()
        let rewards = retrieveRewards().asObservable()
        
        Observable.combineLatest(points, rewards) { ($0, $1) }
            .bind { [weak self] (points, rewards) in
                self?.update(with: points, rewards: rewards)
            }.disposed(by: disposeBag)
    }
    
    private func update(with points: RewardPoints?, rewards: [Reward]?) {
        switch (points, rewards) {
        case (nil, _):
            viewState.accept(ViewState.error(genericErrorModel()))
        case (_, nil):
            viewState.accept(ViewState.error(genericErrorModel()))
        case (let rewardPoints, let rewards):
            pointsRelay.accept(rewardPoints?.points ?? 0)
            mapRewardsToPurchases(rewards: rewards, with: pointsRelay.value)
            viewState.accept(.data)
        }
    }
    
    private func mapRewardsToPurchases(rewards: [Reward]?, with points: Int) {
        self.rewards = rewards ?? []
        purchases = rewards?
            .map {
                return AffiliationPurchase(
                    title: $0.type.cardTitle,
                    partnerIcon: AffiliationPartner.amazon.image,
                    points: $0.points,
                    state: points >= $0.points ? .enabled : .disabled
                )
            } ?? []
    }
    
    private func retrieveAffiliationPoints() -> Single<RewardPoints?> {
        return Single.create(subscribe: { [weak self] (single) -> Disposable in
            self?.rewardsRepository.retrievePoints { result in
                if let points = result.value {
                    single(.success(points))
                } else {
                    single(.success(nil))
                }
            }
            return Disposables.create()
        })
    }
    
    private func retrieveRewards() -> Single<[Reward]?> {
        guard let code = locationManager.currentLocation?.countryCode else { return .just(nil) }
        return Single.create(subscribe: { [weak self] (single) -> Disposable in
            self?.rewardsRepository.indexRewards(countryCode: code, completion: { (result) in
                if result.error != nil {
                    single(.success(nil))
                } else if let rewards = result.value {
                    single(.success(rewards))
                }
            })
            return Disposables.create()
        })
    }
    
    private func costForRedeeming(at index: Int) -> Int {
        return rewards[safeAt: index]?.points ?? 0
    }
    
    func redeem(at index: Int) -> Driver<ViewState> {
        let emptyVM = genericErrorModel()
        
        guard let reward = rewards[safeAt: index],
            let code = locationManager.currentLocation?.countryCode else {
                return .just(.error(emptyVM))
        }
        let id = reward.id
        let newPoints = pointsRelay.value - costForRedeeming(at: index)
        
        let redeem = redeemVoucher(id, code: code).asObservable().share()
        redeem.bind { [weak self] (success) in
            guard success else { return }
            self?.pointsRelay.accept(newPoints)
            }.disposed(by: disposeBag)
        
        return Observable<ViewState>.create { [weak self] (observer) in
            guard let strSelf = self else {
                observer.onNext(ViewState.error(emptyVM))
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onNext(.loading)
            redeem.bind(onNext: { (success) in
                if success {
                    observer.onNext(.data)
                    observer.onCompleted()
                } else {
                    observer.onNext(ViewState.error(emptyVM))
                    observer.onCompleted()
                }
            }).disposed(by: strSelf.disposeBag)
            return Disposables.create()
            }.asDriver(onErrorJustReturn: ViewState.error(emptyVM))
    }
    
    private func redeemVoucher(_ id: String, code: String) -> Single<Bool> {
        return Single.create(subscribe: { [weak self] (single) -> Disposable in
            let params = RewardCreateVoucherParams(rewardId: id, countryCode: code)
            self?.rewardsRepository.createVoucher(parameters: params,
                                                  completion: { (result) in
                                                    if let _ = result.error {
                                                        single(.success(false))
                                                    } else {
                                                        single(.success(true))
                                                    }
            })
            return Disposables.create()
        })
    }
    
    func openHistory() {
        navigator?.openHistory()
    }
    
    func openEditEmail() {
        navigator?.openEditEmail()
    }
    
    fileprivate func genericErrorModel() -> LGEmptyViewModel {
        return LGEmptyViewModel(icon: R.Asset.Affiliation.Error.errorOops.image,
                                title: R.Strings.affiliationStoreUnknownErrorMessage,
                                body: nil,
                                buttonTitle: R.Strings.commonErrorListRetryButton,
                                action: reloadAll,
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: nil,
                                errorCode: nil,
                                errorDescription: nil)
    }
    
    fileprivate func makeInvalidCountry() -> LGEmptyViewModel {
        return LGEmptyViewModel(icon: R.Asset.Affiliation.Error.errorFeatureUnavailable.image,
                                title: R.Strings.affiliationStoreCountryErrorMessage,
                                body: nil,
                                buttonTitle: R.Strings.commonErrorListRetryButton,
                                action: { [weak self] in self?.reloadAll() },
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: nil,
                                errorCode: nil,
                                errorDescription: nil)
    }
}

extension RewardType {
    var cardTitle: String {
        switch self {
        case .amazon5: return R.Strings.affiliationStoreRewardsAmazon5
        case .amazon10: return R.Strings.affiliationStoreRewardsAmazon10
        case .amazon50: return R.Strings.affiliationStoreRewardsAmazon50
        }
    }
}

extension AffiliationStoreViewModel: ReactiveCompatible {}
extension Reactive where Base: AffiliationStoreViewModel {
    var state: Driver<ViewState> {
        return base.viewState.asDriver(onErrorJustReturn: ViewState.error(base.genericErrorModel()))
    }
    
    private var userEmail: Observable<String?> {
        return base.myUserRepository.rx_myUser.asObservable().map { return $0?.email }
    }
    
    var redeemTapped: Driver<RedeemCellModel?> {
        return Observable.combineLatest(base.cellRedeemTapped.asObservable(),
                                        base.rx.userEmail) { RedeemCellModel(index: $0, email: $1) }
            .asDriver(onErrorJustReturn: nil)
    }
    
    var points: Driver<Int> {
        return base.pointsRelay.asDriver()
    }
    
    var pointsAlpha: Driver<CGFloat> {
        return points.map { $0 > 0 ? 1.0 : 0 }
    }
}

struct RedeemCellModel {
    let index: Int
    let email: String?
}
