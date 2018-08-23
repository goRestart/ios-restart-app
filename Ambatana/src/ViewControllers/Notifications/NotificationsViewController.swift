import UIKit
import RxSwift
import LGComponents

class NotificationsViewController: BaseViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: LGEmptyView!
    @IBOutlet weak var tableView: UITableView!

    weak var tabNavigator: TabNavigator?

    fileprivate let refreshControl = UIRefreshControl()
    fileprivate let viewModel: NotificationsViewModel
    fileprivate let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: NotificationsViewModel())
    }

    convenience init(viewModel: NotificationsViewModel) {
        self.init(viewModel: viewModel, nibName: "NotificationsViewController")
    }

    required init(viewModel: NotificationsViewModel, nibName nibNameOrNil: String?) {
         self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)

        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(type: NotificationCenterModularCell.self)
        setupUI()
        setupRX()
        setAccesibilityIds()
    }


    // MARK: - Private methods

    private func setupUI() {
        setNavBarTitle(R.Strings.notificationsTitle)
        
        if viewModel.isNotificationCenterRedesign {
            tableView.backgroundColor = .white
        } else {
            tableView.backgroundColor = UIColor.listBackgroundColor
        }
        
        enableRefreshControl()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = ModularNotificationCellDrawer.estimatedRowHeight
        tableView.contentInset = UIEdgeInsets.zero

        ModularNotificationCellDrawer.registerClassCell(tableView)
    }

    private func setupRX() {
        viewModel.viewState.asObservable().bind { [weak self] state in
            switch state {
            case .loading:
                self?.activityIndicator.startAnimating()
                self?.emptyView.isHidden = true
                self?.tableView.isHidden = true
            case .data:
                self?.activityIndicator.stopAnimating()
                self?.emptyView.isHidden = true
                self?.tableView.isHidden = false
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            case .error(let emptyViewModel):
                self?.setEmptyViewState(emptyViewModel)
            case .empty(let emptyViewModel):
                self?.setEmptyViewState(emptyViewModel)
            }
        }.disposed(by: disposeBag)
        
    }


    // MARK: > Actions

    @objc private func refreshControlTriggered() {
        viewModel.refresh()
    }

    // MARK: > UI

    private func setEmptyViewState(_ emptyViewModel: LGEmptyViewModel) {
        activityIndicator.stopAnimating()
        emptyView.isHidden = false
        tableView.isHidden = true
        emptyView.setupWithModel(emptyViewModel)
    }
    
    private func enableRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered),
                                 for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard viewModel.isNotificationCenterRedesign else { return CGFloat.leastNormalMagnitude }
        return NotificationCenterHeader.Layout.totalHeight
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard viewModel.isNotificationCenterRedesign else { return nil }
        let header = NotificationCenterHeader()
        let title = viewModel.sections[section].sectionDate.title
        header.setup(withTitle: title)
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataCount(atSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellData = viewModel.data(atSection: indexPath.section, atIndex: indexPath.row)
            else { return UITableViewCell() }
        if viewModel.isNotificationCenterRedesign {
            guard let cell = tableView.dequeue(type: NotificationCenterModularCell.self, for: indexPath)
                else { return UITableViewCell() }
            cell.addModularData(with: cellData.modules, isRead: cellData.isRead, notificationCampaign: cellData.campaignType, date: cellData.date)
            cell.delegate = viewModel
            return cell
        } else {
            let cellDrawer = ModularNotificationCellDrawer()
            let cell = cellDrawer.cell(tableView, atIndexPath: indexPath)
            cellDrawer.draw(cell, data: cellData, delegate: viewModel)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectedItemAtIndex(indexPath.row)
    }
}


// MARK: - Scrollable to top

extension NotificationsViewController: ScrollableToTop {
    func scrollToTop() {
        guard let tableView = tableView else { return }
        let position = CGPoint(x: -tableView.contentInset.left, y: -tableView.contentInset.top)
        tableView.setContentOffset(position, animated: true)
    }
}


// MARK: - Accesibility

fileprivate extension NotificationsViewController {
    func setAccesibilityIds() {
        refreshControl.set(accessibilityId: .notificationsRefresh)
        tableView.set(accessibilityId: .notificationsTable)
        activityIndicator.set(accessibilityId: .notificationsLoading)
        emptyView.set(accessibilityId: .notificationsEmptyView)
    }
}
