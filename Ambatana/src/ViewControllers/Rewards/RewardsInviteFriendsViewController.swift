import LGComponents

final class RewardsInviteFriendsViewController: BaseViewController {
    private let viewModel: RewardsInviteFriendsViewModel


    // MARK: Lifecycle

    init(viewModel: RewardsInviteFriendsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: nil)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        title = R.Strings.rewardsInviteFriendsTitle
    }

    private func setupConstraints() {
    }

    private func setAccessibilityIds() {
    }
}
