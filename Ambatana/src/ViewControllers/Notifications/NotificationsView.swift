import UIKit
import LGComponents
import RxCocoa
import RxSwift

final class NotificationsView: UIView {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let refreshControl = UIRefreshControl()
    
    private let loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }()
    
    private var emptyView: LGEmptyView = {
        let emptyView = LGEmptyView()
        emptyView.isHidden = true
        return emptyView
    }()
    
    private var viewModel: NotificationsViewModel?
    private var tableViewController: NotificationsTableViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setAccesibilityIds()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        addSubviewsForAutoLayout([
            tableView, loadingActivityIndicator, emptyView
        ])
 
        tableView.register(type: NotificationCenterModularCell.self)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        
        enableRefreshControl()
    }

    private func setupConstraints() {
        tableView.constraintToEdges(in: self)
        emptyView.constraintToEdges(in: self)
        loadingActivityIndicator.constraintToCenter(in: self)
    }
    
    private func setAccesibilityIds() {
        refreshControl.set(accessibilityId: .notificationsRefresh)
        tableView.set(accessibilityId: .notificationsTable)
        loadingActivityIndicator.set(accessibilityId: .notificationsLoading)
        emptyView.set(accessibilityId: .notificationsEmptyView)
    }
    
    // MARK: - State
    
    func configure(with viewModel: NotificationsViewModel) {
        self.viewModel = viewModel
        
        tableViewController = NotificationsTableViewController(
            viewModel: viewModel
        )

        tableView.backgroundColor = .white
        
        tableView.delegate = tableViewController
        tableView.dataSource = tableViewController
    }
    
    fileprivate func set(_ state: ViewState) {
        switch state {
        case .loading:
            loadingActivityIndicator.startAnimating()
            emptyView.isHidden = true
            tableView.isHidden = true
        case .data:
            loadingActivityIndicator.stopAnimating()
            emptyView.isHidden = true
            tableView.isHidden = false
            refreshControl.endRefreshing()
            tableView.reloadData()
        case .error(let emptyViewModel):
            setEmptyViewState(emptyViewModel)
        case .empty(let emptyViewModel):
            setEmptyViewState(emptyViewModel)
        }
    }
    
    // MARK: - UI controls
    
    private func setEmptyViewState(_ emptyViewModel: LGEmptyViewModel) {
        loadingActivityIndicator.stopAnimating()
        emptyView.isHidden = false
        tableView.isHidden = true
        emptyView.setupWithModel(emptyViewModel)
    }
    
    private func enableRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered),
                                 for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: - Actions
    
    @objc private func refreshControlTriggered() {
        viewModel?.refresh()
    }
    
    func scrollToTop() {
        let position = CGPoint(x: -tableView.contentInset.left, y: -tableView.contentInset.top)
        tableView.setContentOffset(position, animated: true)
    }
}

// MARK: - Bindings

extension Reactive where Base: NotificationsView {
    var state: Binder<ViewState> {
        return Binder(self.base) { view, viewState in
            view.set(viewState)
        }
    }
}

