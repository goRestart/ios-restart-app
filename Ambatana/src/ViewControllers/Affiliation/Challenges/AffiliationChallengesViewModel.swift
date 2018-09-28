import LGComponents
import LGCoreKit
import Result
import RxSwift
import RxCocoa

final class AffiliationChallengesViewModel: BaseViewModel {
    enum State {
        case firstLoad
        case data(AffiliationChallengesDataVM)
        case error(LGEmptyViewModel)

        var isError: Bool {
            guard case .error = self else { return false }
            return true
        }
    }

    private let rewardRepository: RewardRepository
    private let challengerRepository: ChallengerRepository
    private let tracker: Tracker
    private let source: AffiliationChallengesSource

    var state: Driver<State> {
        return stateRelay.asDriver()
    }

    private let stateRelay = BehaviorRelay<State>(value: .firstLoad)
    var isLoading: Driver<Bool> {
        return Driver.combineLatest(stateRelay.asDriver(),
                                    isLoadingRelay.asDriver()) { ($0, $1) }
            .map({ (state, isLoading) -> Bool in
                if case .data(_) = state {
                    return isLoading
                }
                return false
            })
    }
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    var navigator: AffiliationChallengesNavigator?


    // MARK: - Lifecycle

    convenience init(source: AffiliationChallengesSource) {
        self.init(rewardRepository: Core.rewardRepository,
                  challengerRepository: Core.challengerRepository,
                  tracker: TrackerProxy.sharedInstance,
                  source: source)
    }

    init(rewardRepository: RewardRepository,
         challengerRepository: ChallengerRepository,
         tracker: Tracker,
         source: AffiliationChallengesSource) {
        self.rewardRepository = rewardRepository
        self.challengerRepository = challengerRepository
        self.tracker = tracker
        self.source = source
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refresh()
    }


    // MARK: - Actions

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationChallenges()
        return true
    }

    func storeButtonPressed() {
        navigator?.openAffiliationStore()
    }

    func inviteFriendsButtonPressed() {
        navigator?.openAffiliationInviteFriends()
    }

    func faqButtonPressed() {
        navigator?.openAffiliationFAQ()
    }

    func confirmPhoneButtonPressed() {
        navigator?.openConfirmPhone()
    }

    func postListingButtonPressed() {
        navigator?.openPostListing()
    }

    func refreshControlPulled() {
        refresh()
    }


    // MARK: - Data

    private func refresh() {
        let isLoading = isLoadingRelay.value
        guard !isLoading else { return }

        isLoadingRelay.accept(true)

        if stateRelay.value.isError {
            stateRelay.accept(.firstLoad)
        }

        Observable.combineLatest(retrieveWallet().asObservable(),
                                 retrieveChallenges().asObservable()).map {
                                    (walletResult: RepositoryResult<RewardPoints>,
                                    challengesResult: RepositoryResult<[Challenge]>) -> RepositoryResult<AffiliationChallengesDataVM> in
                                    switch (walletResult, challengesResult) {
                                    case let (.success(wallet), .success(challenges)):
                                        return RepositoryResult(value: AffiliationChallengesDataVM(walletPoints: wallet.points,
                                                                                                   challenges: challenges))
                                    case let (_, .failure(error)):
                                        return RepositoryResult(error: error)
                                    case let (.failure(error), _):
                                        return RepositoryResult(error: error)
                                    }
            }.bind { [weak self] result in
                guard let `self` = self else { return }
                self.isLoadingRelay.accept(false)

                if let viewModel = result.value {
                    self.stateRelay.accept(.data(viewModel))
                    self.trackVisit(dataVM: viewModel)
                } else if let _ = result.error  {
                    let errorData = LGEmptyViewModel(icon: R.Asset.Affiliation.Error.errorOops.image,
                                                     title: R.Strings.affiliationChallengesUnknownErrorMessage,
                                                     body: nil,
                                                     buttonTitle: R.Strings.commonErrorListRetryButton,
                                                     action: self.refresh,
                                                     secondaryButtonTitle: nil,
                                                     secondaryAction: nil,
                                                     emptyReason: nil,
                                                     errorCode: nil,
                                                     errorDescription: nil)
                    self.stateRelay.accept(.error(errorData))
                    self.trackVisit(dataVM: nil)
                }
            }.disposed(by: disposeBag)
    }

    private func retrieveWallet() -> Single<RepositoryResult<RewardPoints>> {
        return Single.create { [weak self] single -> Disposable in
            self?.rewardRepository.retrievePoints { result in
                single(.success(result))
            }
            return Disposables.create()
        }
    }

    private func retrieveChallenges() -> Single<RepositoryResult<[Challenge]>> {
        return Single.create { [weak self] single -> Disposable in
            self?.challengerRepository.indexChallenges { result in
               single(.success(result))
            }
            return Disposables.create()
        }
    }


    // MARK: - Tracking

    private func trackVisit(dataVM: AffiliationChallengesDataVM?) {
        let inviteFriendsIsAvailable = dataVM?.challenges.contains(where: { challenge in
            guard case .inviteFriends = challenge else { return false }
            return true
        })
        let joinLetgoChallengeIsAvailable = dataVM?.challenges.contains(where: { challenge in
            guard case .joinLetgo = challenge else { return false }
            return true
        })
        let event = TrackerEvent.rewardCenterOpen(with: source.typePage,
                                                  buttonType: source.buttonType,
                                                  walletPoints: dataVM?.walletPoints,
                                                  inviteFriendsIsAvailable: inviteFriendsIsAvailable,
                                                  joinLetgoChallengeIsAvailable: joinLetgoChallengeIsAvailable)
        tracker.trackEvent(event)
    }
}

private extension AffiliationChallengesSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .feed:
            return .listingList
        case .settings:
            return .settings
        case .external:
            return .external
        }
    }

    var buttonType: EventParameterButtonType? {
        switch self {
        case .feed(let button):
            switch button {
            case .icon:
                return .icon
            case .banner:
                return .banner
            }
        case .settings, .external:
            return nil
        }
    }
}
