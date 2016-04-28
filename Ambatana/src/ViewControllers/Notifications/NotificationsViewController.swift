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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupRX()
    }


    // MARK: - Private methods

    private func setupUI() {

        // Enable refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered),
                                 forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

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

    func vmOpenUser(viewModel: UserViewModel) {
        let userVC = UserViewController(viewModel: viewModel)
        navigationController?.pushViewController(userVC, animated: true)
    }

    func vmOpenProduct(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
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
}
