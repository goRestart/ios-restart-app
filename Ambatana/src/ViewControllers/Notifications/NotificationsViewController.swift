//
//  NotificationsViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

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

        setupUI()
        setupRX()
        setAccesibilityIds()
    }


    // MARK: - Private methods

    private func setupUI() {
        setNavBarTitle(LGLocalizedString.notificationsTitle)
        view.backgroundColor = UIColor.listBackgroundColor

        // Enable refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered),
                                 for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = NotificationCellDrawerFactory.estimatedRowHeight
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        NotificationCellDrawerFactory.registerCells(tableView)
    }

    private func setupRX() {
        viewModel.viewState.asObservable().bindNext { [weak self] state in
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
        }.addDisposableTo(disposeBag)
        
    }


    // MARK: > Actions

    dynamic private func refreshControlTriggered() {
        viewModel.refresh()
    }

    // MARK: > UI

    private func setEmptyViewState(_ emptyViewModel: LGEmptyViewModel) {
        activityIndicator.stopAnimating()
        emptyView.isHidden = false
        tableView.isHidden = true
        emptyView.setupWithModel(emptyViewModel)
        viewModel.emptyStateBecomeVisible(errorReason: emptyViewModel.errorReason)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellData = viewModel.dataAtIndex(indexPath.row) else { return UITableViewCell() }
        let cellDrawer = NotificationCellDrawerFactory.drawerForNotificationData(cellData)
        let cell = cellDrawer.cell(tableView, atIndexPath: indexPath)
        cellDrawer.draw(cell, data: cellData)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectedItemAtIndex(indexPath.row)
    }
}


// MARK: - Scrollable to top

extension NotificationsViewController: ScrollableToTop {
    func scrollToTop() {
        let position = CGPoint(x: -tableView.contentInset.left, y: -tableView.contentInset.top)
        tableView.setContentOffset(position, animated: true)
    }
}


// MARK: - Accesibility

fileprivate extension NotificationsViewController {
    func setAccesibilityIds() {
        refreshControl.accessibilityId = .notificationsRefresh
        tableView.accessibilityId = .notificationsTable
        activityIndicator.accessibilityId = .notificationsLoading
        emptyView.accessibilityId = .notificationsEmptyView
    }
}
