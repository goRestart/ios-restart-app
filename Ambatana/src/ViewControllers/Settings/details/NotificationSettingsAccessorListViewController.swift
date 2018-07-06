import LGComponents
import RxSwift

final class NotificationSettingsAccessorListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let viewModel: NotificationSettingsAccessorListViewModel
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .grayBackground
        tableView.separatorStyle = .none
        tableView.contentInset.top = NotificationSettingsViewController.tableViewTopInset
        tableView.rowHeight = NotificationSettingsAccessorCell.defaultHeight
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        return activityIndicator
    }()
    
    private let placeholderView = NotificationSettingsPlaceholderView()

    
    // MARK: - Lifecycle
    
    required init(viewModel: NotificationSettingsAccessorListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        
        viewModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationSettingsAccessorCell.self,
                           forCellReuseIdentifier: NotificationSettingsAccessorCell.reusableID)
        tableView.register(NotificationSettingSwitchCell.self,
                           forCellReuseIdentifier: NotificationSettingSwitchCell.reusableID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRx()
    }
    
    private func setupRx() {
        viewModel.dataState.asObservable().bind { [weak self] state in
            switch state {
            case .initial, .refreshing:
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
                self?.tableView.isHidden = true
                self?.placeholderView.isHidden = true
            case .loaded:
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
                self?.tableView.reloadData()
                self?.placeholderView.isHidden = true
            case .error:
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = true
                self?.placeholderView.isHidden = false
                self?.placeholderView.setupWith(text: state.placeholderText,
                                                retryText: state.retryText,
                                                retryAction: state.retryAction)
                break
            }
            }.disposed(by: disposeBag)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        switch viewModel.notificationSettingsType {
        case .push:
            title = R.Strings.settingsNotificationsPushNotifications
        case .mail:
            title = R.Strings.settingsNotificationsEmail
        case .marketing, .searchAlerts:
            break
        }
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([tableView, activityIndicator, placeholderView])
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: safeTopAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notificationSettingsCells.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = viewModel.notificationSettingsCells.value[indexPath.row]
        switch cellData {
            case .accessor(let title):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingsAccessorCell.reusableID,
                                                               for: indexPath)
                    as? NotificationSettingsAccessorCell else { return UITableViewCell() }
                cell.setup(withTitle: title)
                return cell
            case .marketing:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingSwitchCell.reusableID, for: indexPath)
                    as? NotificationSettingSwitchCell else { return UITableViewCell() }
                cell.setupWithNotificationSettingCell(cellData)
                return cell
            case .switcher:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard indexPath.row < viewModel.notificationSettings.value.count else { return }
        viewModel.openNotificationSettingsListDetail(notificationSetting: viewModel.notificationSettings.value[indexPath.row])
    }
}
