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

    private let refreshControl = UIRefreshControl()
    private let viewModel: NotificationsViewModel
    private let disposeBag = DisposeBag()

    
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
        self.viewModel.delegate = self

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
                                 forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = NotificationCellDrawerFactory.estimatedRowHeight

        NotificationCellDrawerFactory.registerCells(tableView)
    }

    private func setupRX() {
        viewModel.viewState.asObservable().bindNext { [weak self] state in
            switch state {
            case .Loading:
                self?.activityIndicator.startAnimating()
                self?.emptyView.hidden = true
                self?.tableView.hidden = true
            case .Data:
                self?.activityIndicator.stopAnimating()
                self?.emptyView.hidden = true
                self?.tableView.hidden = false
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            case .Error(let emptyViewModel):
                self?.setEmptyViewState(emptyViewModel)
            case .Empty(let emptyViewModel):
                self?.setEmptyViewState(emptyViewModel)
            }
        }.addDisposableTo(disposeBag)
    }


    // MARK: > Actions

    dynamic private func refreshControlTriggered() {
        viewModel.refresh()
    }

    // MARK: > UI

    private func setEmptyViewState(emptyViewModel: LGEmptyViewModel) {
        activityIndicator.stopAnimating()
        emptyView.hidden = false
        tableView.hidden = true
        emptyView.setupWithModel(emptyViewModel)
    }
}


// MARK: - NotificationsViewModelDelegate

extension NotificationsViewController: NotificationsViewModelDelegate {
    func vmOpenSell() {
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.sellButtonPressed()
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellData = viewModel.dataAtIndex(indexPath.row) else { return UITableViewCell() }
        let cellDrawer = NotificationCellDrawerFactory.drawerForNotificationData(cellData)
        let cell = cellDrawer.cell(tableView, atIndexPath: indexPath)
        cellDrawer.draw(cell, data: cellData)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let cellData = viewModel.dataAtIndex(indexPath.row) else { return }
        cellData.primaryAction()
    }
}


// MARK: - Accesibility

private extension NotificationsViewController {
    func setAccesibilityIds() {
        refreshControl.accessibilityId = .NotificationsRefresh
        tableView.accessibilityId = .NotificationsTable
        activityIndicator.accessibilityId = .NotificationsLoading
        emptyView.accessibilityId = .NotificationsEmptyView
    }
}
