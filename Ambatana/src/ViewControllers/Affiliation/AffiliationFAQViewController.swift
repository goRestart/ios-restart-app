import LGComponents

final class AffiliationFAQViewController: BaseViewController {
    private let viewModel: AffiliationFAQViewModel


    // MARK: Lifecycle

    init(viewModel: AffiliationFAQViewModel) {
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
        title = R.Strings.affiliationFaqTitle
    }

    private func setupConstraints() {
    }

    private func setAccessibilityIds() {
    }
}
