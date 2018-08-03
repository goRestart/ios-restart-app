import FLEX
import bumper
import LGCoreKit
import LGComponents

final class AdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private enum Row {
        case flex, bumper, environment(String), installationId, userId, pushToken, newInstall, removeAndInstall
        
        var title: String {
            switch self {
            case .flex: return "👾 FLEX"
            case .bumper: return "🎪 Bumper Features"
            case .environment: return "⚒ Server Environment"
            case .installationId: return "📱 Installation id"
            case .userId: return "😎 User id"
            case .pushToken: return "📲 Push token"
            case .newInstall: return "🌪 New install"
            case .removeAndInstall: return "⏮ Remove & install"
            }
        }
        
        var subtitle: String {
            let propertyNotFound = "None"
            switch self {
            case .environment(let value): return value
            case .installationId: return Core.installationRepository.installation?.objectId ?? propertyNotFound
            case .userId: return Core.myUserRepository.myUser?.objectId ?? propertyNotFound
            case .pushToken: return Core.installationRepository.installation?.deviceToken ?? propertyNotFound
            case .newInstall: return "Next start will be as a fresh install start (except system permissions)"
            case .removeAndInstall: return "Next start will be as re-install (keeping installation_id)"
            case .flex, .bumper: return ""
            }
        }
        
        func action(adminViewController: AdminViewController) {
            switch self {
            case .flex: adminViewController.openFlex()
            case .bumper: adminViewController.openFeatureToggle()
            case .newInstall: adminViewController.cleanInstall(keepInstallation: false)
            case .removeAndInstall: adminViewController.cleanInstall(keepInstallation: true)
            case .installationId, .userId, .pushToken: UIPasteboard.general.string = subtitle
            case .environment: adminViewController.openServerEnvironmentPicker()
            }
        }
    }
    
    private let isGodMode: Bool
    private var rows: [Row] {
        let env = currentServerEnvironment.rawValue.capitalizedFirstLetterOnly
        if isGodMode {
            return [.flex, .bumper, .environment(env), .installationId, .userId, .pushToken, .newInstall, .removeAndInstall]
        }
        return [.flex, .bumper, .environment(env), .installationId, .userId, .pushToken]
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return tableView
    }()
    
    private var currentServerEnvironment: EnvironmentType
    
    // MARK: - Lifecycle
    
    private init(isGodMode: Bool) {
        self.isGodMode = isGodMode
        currentServerEnvironment = EnvironmentsHelper(godmode: isGodMode).serverEnvironment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    @objc private func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = rows[indexPath.row].title
        cell.detailTextLabel?.text = rows[indexPath.row].subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rows[indexPath.row].action(adminViewController: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    // MARK: - Private
    
    private func setup() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        title = "God Panel"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.Asset.IconsButtons.navbarClose.image,
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: self,
                                                           action: #selector(AdminViewController.closeButtonPressed))
    }
    
    private func openFlex() {
        FLEXManager.shared().showExplorer()
    }
    
    private func openFeatureToggle() {
        let vc = BumperViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openServerEnvironmentPicker() {
        let vc = ServerEnvironmentPicker(selectedEnvironment: currentServerEnvironment, onNewEnvironment: changeEnvironment)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func changeEnvironment(to newEnvironment: EnvironmentType) {
        KeyValueStorage.sharedInstance[.serverEnvironment] = newEnvironment.rawValue
        currentServerEnvironment = newEnvironment
        tableView.reloadData()
        ask(message: "To take effect this change requires relaunching the app. Do you want to kill it now?") {
            exit(0)
        }
    }

    private func cleanInstall(keepInstallation: Bool) {
        let message = keepInstallation ?
            "You're about to reset stored state and bumper information. (Push, location, photos and camera permissions will remain)" :
            "You're about to reset all stored state, bumper and keychain information, installation will be new. (Push, location, photos and camera permissions will remain)"

        ask(message: message, andExecute: { [weak self] in
            GodModeManager.sharedInstance.setCleanInstallOnNextStart(keepingInstallation: keepInstallation)
            if self?.isGodMode ?? false {
                exit(0)
            }
        })
    }

    private func ask(message: String, andExecute action: @escaping () -> Void) {
        let cancelAction = UIAction(interface: .styledText("Cancel", .cancel), action: {})
        let okAction = UIAction(interface: .styledText("Do it!", .standard), action: action)
        showAlert(nil, message: message, actions: [cancelAction, okAction])
    }    
}

extension AdminViewController {
    
    static func make() -> AdminViewController {
        #if GOD_MODE
        let isGodMode = true
        #else
        let isGodMode = false
        #endif
        return AdminViewController(isGodMode: isGodMode)
    }
    
    static func canOpenAdminPanel() -> Bool {
        var compiledInGodMode = false
        #if GOD_MODE
        compiledInGodMode = true
        #endif
        return compiledInGodMode || KeyValueStorage.sharedInstance[.isGod]
    }
}
