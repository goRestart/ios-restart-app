import LGComponents
import RxSwift

final class AffiliationChallengesViewController: BaseViewController {
    private let viewModel: AffiliationChallengesViewModel
    private let dataView = AffiliationChallengesDataView()


    // MARK: - Lifecycle

    init(viewModel: AffiliationChallengesViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: nil,
                   navBarBackgroundStyle: .white)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        title = R.Strings.affiliationChallengesTitle
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        setupDataView()
    }

    private func setupDataView() {
        dataView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dataView)

        dataView.storeButtonPressedCallback = { [weak viewModel] in
            viewModel?.storeButtonPressed()
        }
        dataView.faqButtonPressedCallback = { [weak viewModel] in
            viewModel?.faqButtonPressed()
        }
        dataView.inviteFriendsButtonPressedCallback = { [weak viewModel] in
            viewModel?.inviteFriendsButtonPressed()
        }
        dataView.confirmPhonePressedCallback = { [weak viewModel] in
            viewModel?.confirmPhoneButtonPressed()
        }

        delay(0.3) { [weak dataView] in
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
            let viewModel = AffiliationChallengesDataVM(walletPoints: 65,
                                                        challenges: [Challenge.inviteFriends(inviteFriendsData1),
                                                                     Challenge.inviteFriends(inviteFriendsData2),
                                                                     Challenge.joinLetgo(joinLetgoData1),
                                                                     Challenge.joinLetgo(joinLetgoData2),
                                                                     Challenge.joinLetgo(joinLetgoData3),
                                                                     Challenge.joinLetgo(joinLetgoData4),
                                                                     Challenge.joinLetgo(joinLetgoData5),
                                                                     Challenge.inviteFriends(inviteFriendsData1),
                                                                     Challenge.inviteFriends(inviteFriendsData2)])
            dataView?.set(viewModel: viewModel)
        }
    }

    private func setupConstraints() {
        view.addSubviewsForAutoLayout([dataView])

        let dataViewConstraints = [dataView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                                   dataView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
                                   dataView.topAnchor.constraint(equalTo: safeTopAnchor),
                                   dataView.bottomAnchor.constraint(equalTo: safeBottomAnchor)]
        dataViewConstraints.activate()
    }

    private func setAccessibilityIds() {

    }
}
