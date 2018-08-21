import Foundation
import RxSwift
import RxCocoa
import GoogleSignIn
import LGComponents

enum UserVerificationTableViewSections: Int {
    case verifications = 0
    case personalInfo = 1
    case buyAndSell = 2
}

final class UserVerificationViewController: BaseViewController, GIDSignInUIDelegate {

    private let viewModel: UserVerificationViewModel
    private let disposeBag = DisposeBag()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let navBarView = UserVerificationNavBarView()
    private var items: [[UserVerificationItem]] = []

    private struct Layout {
        static let defaultRowHeight: CGFloat = 70
        static let markAsSoldRowHeight: CGFloat = 82
        static let navBarScoreSize = CGSize(width: 72, height: 32)
        static let sectionHeaderHeight: CGFloat = 66
    }

    init(viewModel: UserVerificationViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
        self.title = R.Strings.profileVerificationsViewTitle
        setupUI()
        bindRx()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        viewModel.loadData()
        setNavBarBackgroundStyle(.white)
    }

    private func setupUI() {
        view.addSubviewForAutoLayout(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(0, 0, Metrics.bigMargin, 0)
        tableView.backgroundColor = .white
        tableView.register(UserVerificationCell.self, forCellReuseIdentifier: UserVerificationCell.reusableID)
        setNavBarBackgroundStyle(.white)
        setupNavBar()
        setupConstraints()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    private func setupNavBar() {
        let button = UIBarButtonItem(customView: navBarView)
        navigationItem.rightBarButtonItem = button
    }

    private func setupConstraints() {
        tableView.layout(with: view).fill()

        if #available(iOS 11.0, *) {} else {
            navBarView.frame.size = Layout.navBarScoreSize
        }
    }

    private func bindRx() {
        viewModel.items.drive(onNext: { [weak self] items in
            self?.items = items
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        Observable
            .combineLatest(viewModel.userAvatar.asObservable(), viewModel.userAvatarPlaceholder.asObservable()) {($0, $1)}
            .subscribeNext { [weak self] (url, placeholder) in
                self?.navBarView.setAvatar(url, placeholderImage: placeholder)
            }
            .disposed(by: disposeBag)

        viewModel.userScore.drive(onNext: { [weak self] score in
            self?.navBarView.score = score
        }).disposed(by: disposeBag)
    }
}

extension UserVerificationViewController: UserVerificationViewModelDelegate {
    func startAvatarSelection() {
        MediaPickerManager.showImagePickerIn(self)
    }
}

extension UserVerificationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Layout.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = UserVerificationTableViewSections(rawValue: section) else { return nil }
        switch section {
        case .verifications:
            let view = UserVerificationMainSectionHeader()
            view.title = R.Strings.profileVerificationsViewVerifySectionTitle
            view.subtitle = R.Strings.profileVerificationsViewVerifySectionSubtitle
            return view
        case .personalInfo:
            let view = UserVerificationSectionHeader()
            view.title = R.Strings.profileVerificationsViewAddInfoSectionTitle
            return view
        case .buyAndSell:
            let view = UserVerificationSectionHeader()
            view.title = R.Strings.profileVerificationsViewExtraSectionTitle
            return view
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < items.count else { return 0 }
        return items[section].count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = UserVerificationTableViewSections(rawValue: indexPath.section) else { return 0 }
        switch section {
        case .personalInfo, .verifications: return Layout.defaultRowHeight
        case .buyAndSell: return Layout.markAsSoldRowHeight
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserVerificationCell.reusableID,
                                                                       for: indexPath)
        guard let verifyCell = cell as? UserVerificationCell else { return UITableViewCell() }
        let item = items[indexPath.section][indexPath.row]
        verifyCell.configure(with: item)
        setAccessibilityIdTo(cell: cell, with: item)
        return verifyCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.section][indexPath.row]
        guard item.canBeSelected else { return }
        viewModel.didSelect(item: item)
    }

    private func setAccessibilityIdTo(cell: UITableViewCell, with item: UserVerificationItem) {
        let accessibilityId: AccessibilityId
        switch item {
        case .facebook: accessibilityId = .verificationsFacebookOption
        case .google: accessibilityId = .verificationsGoogleOption
        case .email: accessibilityId = .verificationsEmailOption
        case .phoneNumber: accessibilityId = .verificationsPhoneNumberOption
        case .photoID: accessibilityId = .verificationsPhotoIDOption
        case .profilePicture: accessibilityId = .verificationsAvatarOption
        case .bio: accessibilityId = .verificationsBioOption
        case .markAsSold: accessibilityId = .verificationsMarkAsSoldOption
        }
        cell.set(accessibilityId: accessibilityId)
    }
}

extension UserVerificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        dismiss(animated: true, completion: nil)
        guard let theImage = image else { return }
        viewModel.updateAvatar(with: theImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
