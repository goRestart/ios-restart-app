import LGComponents
import RxSwift

final class NotificationSettingsListDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let viewModel: NotificationSettingsListDetailViewModel
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .grayBackground
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset.top = NotificationSettingsViewController.tableViewTopInset
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        return activityIndicator
    }()
    
    
    // MARK: - Lifecycle
    
    required init(viewModel: NotificationSettingsListDetailViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        
        viewModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
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
        viewModel.settings.asObservable().subscribeNext { [weak self] _ in
            self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        title = viewModel.notificationSetting.name
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([tableView, activityIndicator])
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    // MARK: - UITableViewDataSource, UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupSettings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingSwitchCell.reusableID,
                                                       for: indexPath)
            as? NotificationSettingSwitchCell else { return UITableViewCell() }
        let notificationSettingCell = viewModel.settings.value[indexPath.row]
        cell.setupWithNotificationSettingCell(notificationSettingCell)
        return cell
    }
}
