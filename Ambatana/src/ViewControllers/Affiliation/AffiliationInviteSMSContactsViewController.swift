import LGComponents

final class AffiliationInviteSMSContactsViewController: BaseViewController {
    private let viewModel: AffiliationInviteSMSContactsViewModel


    // MARK: Lifecycle

    init(viewModel: AffiliationInviteSMSContactsViewModel) {
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
        title = R.Strings.affiliationInviteSmsContactsTitle
    }

    private func setupConstraints() {
    }

    private func setAccessibilityIds() {
    }
}

