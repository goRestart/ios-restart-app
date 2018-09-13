import UIKit
import FBSDKShareKit
import RxSwift
import LGComponents

class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingProfileImageView: UIView!
    @IBOutlet weak var settingProfileImageLabel: UILabel!
    @IBOutlet weak var settingProfileImageProgressView: UIProgressView!

    fileprivate let viewModel: SettingsViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "SettingsViewController")
        self.viewModel.delegate = self
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAccessibilityIds()
        setupRx()
    }

    deinit {
        /* @ahl: This is because of a crash in iOS8; logout+login, check: https://ambatana.atlassian.net/browse/ABIOS-1639
           Explanation here:
           http://stackoverflow.com/questions/5499913/pop-to-root-view-controller-without-animation-crash-for-the-table-view */
        tableView.delegate = nil
        tableView.dataSource = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }


    // MARK: - Private

    private func setupUI() {
        settingProfileImageLabel.text = R.Strings.settingsChangeProfilePictureLoading
        settingProfileImageView.isHidden = true
        setNavBarTitle(R.Strings.settingsTitle)
    
        let cellNib = UINib(nibName: SettingsCell.reusableID, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: SettingsCell.reusableID)
        let logoutCellNib = UINib(nibName: SettingsLogoutCell.reusableID, bundle: nil)
        tableView.register(logoutCellNib, forCellReuseIdentifier: SettingsLogoutCell.reusableID)
        let infoCellNib = UINib(nibName: SettingsInfoCell.reusableID, bundle: nil)
        tableView.register(infoCellNib, forCellReuseIdentifier: SettingsInfoCell.reusableID)
        tableView.backgroundColor = UIColor.grayBackground
        tableView.contentInset.bottom = 15
        automaticallyAdjustsScrollViewInsets = false
    }

    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .settingsList)
    }

    private func setupRx() {
        viewModel.avatarLoadingProgress.asObservable().bind { [weak self] progress in
            if let progress = progress {
                onMainThread { [weak self] in
                    self?.settingProfileImageProgressView.setProgress(progress, animated: true)
                }
                self?.settingProfileImageView.isHidden = false
            } else {
                self?.settingProfileImageView.isHidden = true
            }
        }.disposed(by: disposeBag)

        viewModel.sections.asObservable().bind { [weak self] _ in
            self?.tableView?.reloadData()
        }.disposed(by: disposeBag)
    }
}


// MARK: - TableView

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    private static let headerHeight: CGFloat = 50
    private static let emptyHeaderHeight: CGFloat = 30

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let title = viewModel.sectionTitle(section)
        return title.isEmpty ? SettingsViewController.emptyHeaderHeight : SettingsViewController.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SettingsTableViewHeader()
        let title = viewModel.sectionTitle(section)
        header.setup(withTitle: title)
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsCount(section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let setting = viewModel.settingAtSection(indexPath.section, index: indexPath.row) else { return 0 }
        return setting.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let setting = viewModel.settingAtSection(indexPath.section, index: indexPath.row) else { return UITableViewCell() }
        switch setting {
        case .logOut:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsLogoutCell.reusableID, for: indexPath)
                as? SettingsLogoutCell else { return UITableViewCell() }
            return cell
        case .versionInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInfoCell.reusableID, for: indexPath)
                as? SettingsInfoCell else { return UITableViewCell() }
            cell.refreshData()
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reusableID, for: indexPath)
                as? SettingsCell else { return UITableViewCell() }
            cell.setupWithSetting(setting)
            cell.showBottomBorder = indexPath.row < viewModel.settingsCount(indexPath.section) - 1
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.settingSelectedAtSection(indexPath.section, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Grouped tableview need empty footer to avoid default footer.
        return LGUIKitConstants.onePixelSize
    }
}


// MARK: - SettingsViewModelDelegate 

extension SettingsViewController: SettingsViewModelDelegate {
    func vmOpenImagePick() {
        MediaPickerManager.showImagePickerIn(self)
    }
}


// MARK: - Image Pick

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        self.dismiss(animated: true, completion: nil)
        guard let theImage = image else { return }
        viewModel.imageSelected(theImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - FBSDKAppInviteDialogDelegate

extension SettingsViewController: FBSDKAppInviteDialogDelegate {

    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        guard let _ = results else {
            viewModel.fbAppInviteCancel()
            return
        }
        if let completionGesture = results["completionGesture"] as? String, completionGesture == "cancel"{
            viewModel.fbAppInviteCancel()
            return
        }
        viewModel.fbAppInviteDone()
    }

    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        viewModel.fbAppInviteFailed()
    }
}


// MARK: - LetGoSetting UI

extension LetGoSetting {

    var cellHeight: CGFloat {
        switch self {
        case .changePhoto, .changeUsername, .changeEmail, .changeLocation, .changePassword, .help,
             .termsAndConditions, .privacyPolicy, .changeUserBio, .notifications, .rewards:
            return 50
        case .logOut:
            return 44
        case .versionInfo:
            return 30
        }
    }
}
