import LGComponents
import RxSwift

final class AffiliationChallengesViewController: BaseViewController {
    private let viewModel: AffiliationChallengesViewModel
    private let disposeBag = DisposeBag()

    private let inviteFriendsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(R.Strings.affiliationChallengesInviteFriendsButton, for: .normal)
        return button
    }()

    private let faqButton: UIButton = UIButton(type: .infoDark)


    // MARK: Lifecycle

    init(viewModel: AffiliationChallengesViewModel) {
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
        title = R.Strings.affiliationChallengesTitle
        setupInviteFriendsButton()
        setupFAQButton()
    }

    private func setupInviteFriendsButton() {
        inviteFriendsButton.rx.tap.bind { [weak viewModel] in
            viewModel?.inviteFriendsButtonPressed()
        }.disposed(by: disposeBag)
    }

    private func setupFAQButton() {
        faqButton.rx.tap.bind { [weak viewModel] in
            viewModel?.faqButtonPressed()
        }.disposed(by: disposeBag)
    }

    private func setupConstraints() {
        view.addSubviewsForAutoLayout([inviteFriendsButton, faqButton])

        let inviteFriendsButtonConstraints = [inviteFriendsButton.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                                              inviteFriendsButton.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
                                              inviteFriendsButton.topAnchor.constraint(equalTo: safeTopAnchor)]
        inviteFriendsButtonConstraints.activate()

        let faqButtonConstraints = [faqButton.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                                    faqButton.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
                                    faqButton.topAnchor.constraint(equalTo: inviteFriendsButton.bottomAnchor)]
        faqButtonConstraints.activate()
    }

    private func setAccessibilityIds() {

    }
}
