import LGComponents

final class RewardsViewModel: BaseViewModel {
    var navigator: RewardsNavigator?

    override func backButtonPressed() -> Bool {
        navigator?.closeRewards()
        return true
    }

    func inviteFriendsButtonPressed() {
        navigator?.openRewardsInviteFriends()
    }

    func faqButtonPressed() {
        navigator?.openRewardsFAQ()
    }
}
