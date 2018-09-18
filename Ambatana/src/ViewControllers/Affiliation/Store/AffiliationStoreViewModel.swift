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
    let points: String

    let state: State
}

final class AffiliationStoreViewModel: BaseViewModel {
    private let rewardsRepository: RewardRepository
    private let locationManager: LocationManager

    fileprivate let pointsState = PublishSubject<ViewState>()
    fileprivate let rewardsState = PublishSubject<ViewState>()

    var navigator: AffiliationStoreNavigator?

    private(set) var purchases: [AffiliationPurchase] = []
    private(set) var rewardPoints: RewardPoints? = nil
    var points: Int { return rewardPoints?.points ?? 0 }

    var moreActions: [UIAction] {
        return [UIAction(interface: .text(R.Strings.affiliationStoreHistory),
                         action: { [weak self] in self?.openHistory() })]
    }

    convenience override init() {
        self.init(rewardsRepository: Core.rewardRepository,
                  locationManager: Core.locationManager)
    }

    init(rewardsRepository: RewardRepository,
         locationManager: LocationManager) {
        self.rewardsRepository = rewardsRepository
        self.locationManager = locationManager
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        reloadAll()
    }

    private func reloadAll() {
        retrievePurchases()
        retrievePoints()
    }

    private func retrievePoints() {
        pointsState.onNext(.loading)
        rewardsRepository.retrievePoints { [weak self] result in
            self?.updatePoints(with: result)
        }
    }

    private func updatePoints(with result: Result<RewardPoints, RepositoryError>) {
        if let error = result.error {
            pointsState.onNext(.empty(makeEmpty()))
        } else if let value = result.value {
            rewardPoints = value
            pointsState.onNext(.data)
        } else {
            pointsState.onNext(.empty(makeEmpty()))
        }
    }

    private func retrievePurchases() {
        rewardsState.onNext(.loading)
        guard let code = locationManager.currentLocation?.countryCode else { return }
        rewardsRepository.indexRewards(countryCode: code) { [weak self] result in
            self?.updateRewards(with: result)
        }
    }

    private func updateRewards(with result: Result<[Reward], RepositoryError>) {
        if let error = result.error {
            rewardsState.onNext(.error(makeEmpty()))
        } else if let rewards = result.value, rewards.count > 0 {
            purchases = rewards
                .sorted(by: { (r1, r2) -> Bool in
                    return r1.points < r2.points
                }).map {
                    return AffiliationPurchase(title: $0.type.cardTitle,
                                               partnerIcon: AffiliationPartner.amazon.image,
                                               points: "\($0.points)",state: .enabled) }
            rewardsState.onNext(.data)
        } else {
            rewardsState.onNext(.empty(makeEmpty()))
        }
    }

    private func openHistory() {
        navigator?.openHistory()
    }

    fileprivate func makeEmpty() -> LGEmptyViewModel {
        return LGEmptyViewModel(icon: R.Asset.Affiliation.Error.errorOops.image,
                                title: R.Strings.affiliationStoreUnknownErrorMessage,
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

private extension RewardType {
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
        let points: Observable<ViewState> = base.pointsState.asObservable()
        let rewards: Observable<ViewState> = base.rewardsState.asObservable()
        return Observable.combineLatest(points, rewards) { return ($0, $1) }
            .map { tuple -> ViewState in
                let points = tuple.0
                let rewards = tuple.1
                return ViewState.combine(v1: points, v2: rewards)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: ViewState.error(base.makeEmpty()))
    }
}

private extension ViewState {
    static func combine(v1: ViewState, v2: ViewState) -> ViewState {
        if v1 == .loading || v2 == .loading {
            return .loading
        } else if case .error(let model) = v1 {
            return ViewState.error(model)
        } else  if case .error(let model) = v2 {
            return ViewState.error(model)
        }  else if case .empty(let model) = v1 {
            return ViewState.empty(model)
        } else if  case .empty(let model) = v2 {
            return ViewState.empty(model)
        }
        return .data
    }
}
