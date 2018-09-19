import LGComponents
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

    var state: Driver<State> {
        return stateRelay.asDriver()
    }
    private let stateRelay = BehaviorRelay<State>(value: .firstLoad)
    var isLoading: Driver<Bool> {
        return isLoadingRelay.asDriver()
    }
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    var navigator: AffiliationChallengesNavigator?


    // MARK: - Lifecycle

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
        guard !isLoadingRelay.value else { return }
        isLoadingRelay.accept(true)

        if stateRelay.value.isError {
            stateRelay.accept(.firstLoad)
        }

        Observable.combineLatest(retrieveWallet(), retrieveChallenges()) {
            return AffiliationChallengesDataVM(walletPoints: $0,
                                               challenges: $1)
            }.bind { [weak stateRelay, weak isLoadingRelay] viewModel in
                let success = Bool.makeRandom()
                if success {
                    stateRelay?.accept(.data(viewModel))
                } else {
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
                    stateRelay?.accept(.error(errorData))
                }
                isLoadingRelay?.accept(false)
            }.disposed(by: disposeBag)
    }

    private func retrieveWallet() -> Observable<Int> {
        return Observable.create { observer -> Disposable in
            delay(0.2) {
                observer.onNext(65)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    private func retrieveChallenges() -> Observable<[Challenge]> {
        return Observable.create { observer -> Disposable in
            let joinLetgoData1 = ChallengeJoinLetgoData(stepsCount: 2,
                                                        stepsCompleted: [],
                                                        pointsReward: 5,
                                                        status: .ongoing)
            let joinLetgoData2 = ChallengeJoinLetgoData(stepsCount: 2,
                                                        stepsCompleted: [.phoneVerification],
                                                        pointsReward: 5,
                                                        status: .ongoing)
            let joinLetgoData3 = ChallengeJoinLetgoData(stepsCount: 2,
                                                        stepsCompleted: [.listingPosted],
                                                        pointsReward: 5,
                                                        status: .ongoing)
            let joinLetgoData4 = ChallengeJoinLetgoData(stepsCount: 2,
                                                        stepsCompleted: [.phoneVerification, .listingPosted],
                                                        pointsReward: 5,
                                                        status: .ongoing)
            let joinLetgoData5 = ChallengeJoinLetgoData(stepsCount: 2,
                                                        stepsCompleted: [.phoneVerification, .listingPosted],
                                                        pointsReward: 5,
                                                        status: .completed)
            let inviteFriendsData1 = ChallengeInviteFriendsData(milestones: [ChallengeMilestone(stepIndex: 3,
                                                                                                pointsReward: 10),
                                                                             ChallengeMilestone(stepIndex: 10,
                                                                                                pointsReward: 50)],
                                                                stepsCount: 10,
                                                                currentStep: 2,
                                                                status: .ongoing)
            let inviteFriendsData2 = ChallengeInviteFriendsData(milestones: [ChallengeMilestone(stepIndex: 3,
                                                                                                pointsReward: 10),
                                                                             ChallengeMilestone(stepIndex: 10,
                                                                                                pointsReward: 50)],
                                                                stepsCount: 10,
                                                                currentStep: 10,
                                                                status: .completed)
            let challenges = [Challenge.inviteFriends(inviteFriendsData1),
                              Challenge.inviteFriends(inviteFriendsData2),
                              Challenge.joinLetgo(joinLetgoData1),
                              Challenge.joinLetgo(joinLetgoData2),
                              Challenge.joinLetgo(joinLetgoData3),
                              Challenge.joinLetgo(joinLetgoData4),
                              Challenge.joinLetgo(joinLetgoData5),
                              Challenge.inviteFriends(inviteFriendsData1),
                              Challenge.inviteFriends(inviteFriendsData2)]
            delay(0.3) {
                observer.onNext(challenges)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
