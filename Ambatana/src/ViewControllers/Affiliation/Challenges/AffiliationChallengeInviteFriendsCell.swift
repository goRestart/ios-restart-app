import LGComponents
import LGCoreKit
import UIKit

final class AffiliationChallengeInviteFriendsCell: UITableViewCell {
    static let completedIdentifier = "AffiliationChallengeInviteFriendsCell.completed"
    static let ongoingIdentifier = "AffiliationChallengeInviteFriendsCell.ongoing"

    private let challengeView = AffiliationChallengeView(style: .progress)

    var faqButtonPressedCallback: (() -> ())? {
        get { return challengeView.faqButtonPressedCallback }
        set { challengeView.faqButtonPressedCallback = newValue }
    }
    var inviteFriendsPressedCallback: (() -> ())? {
        get { return challengeView.buttonPressedCallback }
        set { challengeView.buttonPressedCallback = newValue }
    }


    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewForAutoLayout(challengeView)
        let constraints = [challengeView.leadingAnchor.constraint(equalTo: leadingAnchor),
                           challengeView.trailingAnchor.constraint(equalTo: trailingAnchor),
                           challengeView.topAnchor.constraint(equalTo: topAnchor),
                           challengeView.bottomAnchor.constraint(equalTo: bottomAnchor)]
        constraints.activate()

        challengeView.set(title: R.Strings.affiliationChallengesInviteFriendsTitle)
        challengeView.set(subtitle: R.Strings.affiliationChallengesInviteFriendsSubtitle)
        challengeView.set(buttonTitle: R.Strings.affiliationChallengesInviteFriendsButton)
    }


    // MARK: - Setup

    func setup(data: ChallengeInviteFriendsData) {
        challengeView.setup(inviteFriendsData: data)

        guard let milestone1 = data.milestones[safeAt: 0],
            let milestone2 = data.milestones[safeAt: 1] else { return }
        challengeView.set(description: R.Strings.affiliationChallengesInviteFriendsDescription("\(milestone1.stepIndex)",
                                                                                               "\(milestone1.pointsReward)",
                                                                                               "\(milestone2.stepIndex)",
                                                                                               "\(milestone2.pointsReward)"))
    }
}
