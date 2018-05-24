import RxSwift
import LGComponents

final class SettingsNotificationsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    private static let tableViewTopInset: CGFloat = 35

    private let tableView = UITableView()
    
    private let viewModel: SettingsNotificationsViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    required init(viewModel: SettingsNotificationsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
        setupRx()
    }
    
    private func setupUI() {
        setNavBarTitle(R.Strings.settingsTitle)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.backgroundColor = .grayBackground
        tableView.contentInset.top = SettingsNotificationsViewController.tableViewTopInset
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsNotificationsSwitchCell.self,
                           forCellReuseIdentifier: SettingsNotificationsSwitchCell.reusableID)
        tableView.register(SettingsNotificationsSearchAlertsCell.self,
                           forCellReuseIdentifier: SettingsNotificationsSearchAlertsCell.reusableID)
    }
    
    private func setupConstraints() {
        view.addSubviewForAutoLayout(tableView)
        
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: topBarHeight),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupRx() {
        viewModel.settings.asDriver().drive(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .settingsList)
    }
    
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let setting = viewModel.settingAtIndex(indexPath.row) else { return 0 }
        return setting.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let setting = viewModel.settingAtIndex(indexPath.row) else { return UITableViewCell() }
        switch setting {
        case .marketingNotifications:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsNotificationsSwitchCell.reusableID, for: indexPath)
                as? SettingsNotificationsSwitchCell else { return UITableViewCell() }
            cell.setupWithSetting(setting)
            return cell
        case .searchAlerts:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsNotificationsSearchAlertsCell.reusableID, for: indexPath)
                as? SettingsNotificationsSearchAlertsCell else { return UITableViewCell() }
            cell.setupWithSetting(setting)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.settingSelectedAtIndex(indexPath.row)
    }
}
