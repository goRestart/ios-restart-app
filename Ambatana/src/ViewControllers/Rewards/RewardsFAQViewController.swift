import LGComponents

final class RewardsFAQViewController: BaseViewController {
    private let viewModel: RewardsFAQViewModel


    // MARK: Lifecycle

    init(viewModel: RewardsFAQViewModel) {
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
        title = R.Strings.rewardsFaqTitle
    }

    private func setupConstraints() {
    }

    private func setAccessibilityIds() {
    }
}
