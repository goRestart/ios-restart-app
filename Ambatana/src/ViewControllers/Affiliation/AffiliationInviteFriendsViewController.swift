import LGComponents
import RxSwift

final class AffiliationInviteFriendsViewController: BaseViewController {
    private let viewModel: AffiliationInviteFriendsViewModel
    private let disposeBag = DisposeBag()

    private let inviteContactsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(R.Strings.affiliationInviteFriendsSmsButton, for: .normal)
        return button
    }()

    
    // MARK: Lifecycle

    init(viewModel: AffiliationInviteFriendsViewModel) {
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
        title = R.Strings.affiliationInviteFriendsTitle
        setupInviteContactsButton()
    }

    private func setupInviteContactsButton() {
        inviteContactsButton.rx.tap.bind { [weak viewModel] in
            viewModel?.inviteSMSContactsButtonPressed()
        }.disposed(by: disposeBag)
    }

    private func setupConstraints() {
        view.addSubviewsForAutoLayout([inviteContactsButton])

        let inviteContactsButtonConstraints = [inviteContactsButton.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                                               inviteContactsButton.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
                                               inviteContactsButton.topAnchor.constraint(equalTo: safeTopAnchor)]
        inviteContactsButtonConstraints.activate()
    }


    private func setAccessibilityIds() {
    }
}
