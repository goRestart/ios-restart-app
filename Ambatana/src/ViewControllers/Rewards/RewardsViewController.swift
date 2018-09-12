import LGComponents

final class RewardsViewController: BaseViewController {
    private let viewModel: RewardsViewModel

    
    // MARK: Lifecycle

    init(viewModel: RewardsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
