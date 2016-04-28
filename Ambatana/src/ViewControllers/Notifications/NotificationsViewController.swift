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
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private let viewModel: NotificationsViewModel


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
    }





    // MARK: - Private methods

    private func setupUI() {

        // Enable refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered),
                                 forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        
    }

    private func setupRX() {

    }


    // MARK: > Actions
    dynamic private func refreshControlTriggered() {

    }
}


// MARK: - NotificationsViewModelDelegate

extension NotificationsViewController: NotificationsViewModelDelegate {

}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
