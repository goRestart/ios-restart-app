import LGComponents
import RxSwift

final class AffiliationInviteFriendsViewController: BaseViewController {
    private let viewModel: AffiliationInviteFriendsViewModel
    private let disposeBag = DisposeBag()

    private enum Layout {
        static let labelLeadingMargin: CGFloat = 16
        static let labelTopMargin: CGFloat = 16
        static let labelTrailingMargin: CGFloat = 16
        static let buttonHeight: CGFloat = 44
        static let termsButtonHeight: CGFloat = 22
        static let termsButtonBottomMargin: CGFloat = 12
        static let termsButtonTopMargin: CGFloat = 21
    }
    
    private let inviteContactsButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.affiliationInviteFriendsSmsButton, for: .normal)
        return button
    }()
    
    private let inviteOthersButton: UIButton = {
        let button = LetgoButton(withStyle: .secondary(fontSize: .small, withBorder: true))
        button.setTitle(R.Strings.affiliationInviteFriendsOthersButton, for: .normal)
        return button
    }()
    
    private let termsAndConditionsButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.Strings.affiliationInviteFriendsTermsButton, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemBoldFont(size: 16)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemBoldFont(size: 32)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.text = R.Strings.affiliationInviteFriendsTitleLabel
        return titleLabel
    }()
    
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemRegularFont(size: 16)
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = R.Strings.affiliationInviteFriendsSubtitleLabel
        return subtitleLabel
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

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        title = R.Strings.affiliationInviteFriendsTitle
        view.backgroundColor = .white
        setupInviteOthersButton()
        setupInviteContactsButton()
        setupTermsButton()
    }

    private func setupInviteContactsButton() {
        inviteContactsButton.rx.tap.bind { [weak viewModel] in
            viewModel?.inviteSMSContactsButtonPressed()
        }.disposed(by: disposeBag)
    }
    
    private func setupInviteOthersButton() {
        inviteOthersButton.rx.tap.bind { [weak viewModel] in
           // viewModel?.inviteOthersButtonPressed
            }.disposed(by: disposeBag)
    }

    private func setupTermsButton() {
        termsAndConditionsButton.rx.tap.bind { [weak viewModel] in
            viewModel?.termsButtonPressed()
            }.disposed(by: disposeBag)
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([titleLabel, subtitleLabel, inviteContactsButton, inviteOthersButton, termsAndConditionsButton])

        let titleConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.labelLeadingMargin),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.labelTrailingMargin),
            titleLabel.safeTopAnchor.constraint(equalTo: view.safeTopAnchor, constant: Layout.labelTopMargin)
        ]
        
        let subtitleLabelConstraints = [
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.labelLeadingMargin),
             subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.labelTrailingMargin),
            subtitleLabel.safeTopAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.labelTopMargin)
        ]
        
        let termsAndConditionsButtonConstraints = [
            termsAndConditionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.labelLeadingMargin),
            termsAndConditionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.labelTrailingMargin),
            termsAndConditionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Layout.termsButtonBottomMargin),
            termsAndConditionsButton.heightAnchor.constraint(equalToConstant: Layout.termsButtonHeight)
        ]
        
        let inviteOthersButtonConstraints = [
            inviteOthersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.labelLeadingMargin),
            inviteOthersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.labelTrailingMargin),
            inviteOthersButton.bottomAnchor.constraint(equalTo: termsAndConditionsButton.topAnchor, constant: -Layout.termsButtonTopMargin),
            inviteOthersButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ]
        
        let inviteContactsButtonConstraints = [
            inviteContactsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.labelLeadingMargin),
            inviteContactsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.labelTrailingMargin),
            inviteContactsButton.bottomAnchor.constraint(equalTo: inviteOthersButton.topAnchor, constant: -Layout.labelTopMargin),
            inviteContactsButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ]
        NSLayoutConstraint.activate([titleConstraints, subtitleLabelConstraints, termsAndConditionsButtonConstraints, inviteOthersButtonConstraints, inviteContactsButtonConstraints].flatMap {$0})
    }


    private func setAccessibilityIds() {
    }
}
