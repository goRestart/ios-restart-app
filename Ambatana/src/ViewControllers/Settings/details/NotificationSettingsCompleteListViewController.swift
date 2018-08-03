import LGComponents
import RxSwift

final class NotificationSettingsCompleteListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let viewModel: NotificationSettingsCompleteListViewModel
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .grayBackground
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0.0
        tableView.estimatedRowHeight = NotificationSettingSwitchCell.defaultHeight
        return tableView
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        return activityIndicator
    }()
    private let placeholderView = NotificationSettingsPlaceholderView()
    

    // MARK: - Lifecycle
    
    required init(viewModel: NotificationSettingsCompleteListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        
        viewModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(type: NotificationSettingSwitchCell.self)
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
        viewModel.dataState.asDriver().drive(onNext: { [weak self] state in
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
            }
            }).disposed(by: disposeBag)
        
        viewModel.sections.asObservable().subscribeNext { [weak self] _ in
            self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        switch viewModel.notificationSettingsType {
        case .push:
            title = R.Strings.settingsNotificationsPushNotifications
        case .mail:
            title = R.Strings.settingsNotificationsEmail
        case .searchAlerts, .marketing:
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsTableViewHeader.Layout.totalHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SettingsTableViewHeader()
        let title = viewModel.sections.value[section].title
        header.setup(withTitle: title)
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections.value[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = viewModel.cellDataFor(section: indexPath.section, row: indexPath.row)
        switch cellData {
        case .switcher:
            guard let cell = tableView.dequeue(type: NotificationSettingSwitchCell.self, for: indexPath)
                else { return UITableViewCell() }
            cell.setupWithNotificationSettingCell(cellData)
            return cell
        case .marketing:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingSwitchCell.reusableID, for: indexPath)
                as? NotificationSettingSwitchCell else { return UITableViewCell() }
            cell.setupWithNotificationSettingCell(cellData)
            return cell
        case .accessor:
            return UITableViewCell()
        }
    }
}
