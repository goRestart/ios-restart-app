import LGComponents
import UIKit

final class AffiliationChallengeJoinLetgoCell: UITableViewCell {
    static let completedIdentifier = "AffiliationChallengeJoinLetgoCell.completed"
    static let ongoingIdentifier = "AffiliationChallengeJoinLetgoCell.ongoing"

    private let challengeView = AffiliationChallengeView(style: .steps(count: 2))

    var faqButtonPressedCallback: (() -> ())? {
        get { return challengeView.faqButtonPressedCallback }
        set { challengeView.faqButtonPressedCallback = newValue }
    }
    var buttonPressedCallback: (() -> ())? {
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

        challengeView.set(title: R.Strings.affiliationChallengesJoinLetgoTitle)
        challengeView.set(subtitle: R.Strings.affiliationChallengesJoinLetgoSubtitle)
    }


    // MARK: - Setup

    func setup(data: ChallengeJoinLetgoData) {
        challengeView.setup(joinLetgoData: data)

        let isPhoneConfirmed = data.stepsCompleted.contains(.phoneVerification)
        let isListingPosted = data.stepsCompleted.contains(.listingPosted)
        switch (isPhoneConfirmed, isListingPosted) {
        case (false, _):
            challengeView.set(buttonTitle: R.Strings.affiliationChallengesJoinLetgoStepPhoneButton)
        case (true, false):
            challengeView.set(buttonTitle: R.Strings.affiliationChallengesJoinLetgoStepPostButton)
        case (true, true):
            challengeView.set(buttonTitle: "")
        }
    }
}
