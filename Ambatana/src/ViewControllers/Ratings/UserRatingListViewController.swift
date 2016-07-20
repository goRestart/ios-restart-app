//
//  UserRatingListViewController.swift
//  LetGo
//
//  Created by Dídac on 18/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

class UserRatingListViewController: BaseViewController {

    static var cellReuseIdentifier = "UserRatingCell"

    @IBOutlet weak var tableView: UITableView!


    private var viewModel: UserRatingListViewModel!


    convenience init() {
        self.init(viewModel: UserRatingListViewModel(userId: nil))
    }

    convenience init(viewModel: UserRatingListViewModel) {
        self.init(viewModel: viewModel, nibName: "UserRatingListViewController")
    }

    required init(viewModel: UserRatingListViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func setupUI() {
        let cellNib = UINib(nibName: UserRatingListViewController.cellReuseIdentifier, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: UserRatingListViewController.cellReuseIdentifier)

        view.backgroundColor = UIColor.listBackgroundColor
    }


}


// MARK: UserRatingListViewModelDelegate

extension UserRatingListViewController: UserRatingListViewModelDelegate {

    func vmDidLoadUserRatings(ratings: [UserRating]) {
        tableView.reloadData()
    }

    func vmDidFailLoadingUserRatings() {
        
    }

    func showActionSheetForCellAtIndex(cancelAction: UIAction, actions: [UIAction]) {
        vmShowActionSheet(cancelAction, actions: actions)
    }
}

// MARK: UITableView Delegate

extension UserRatingListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ratings.count
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 1000
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(UserRatingListViewController.cellReuseIdentifier,
                                                                     forIndexPath: indexPath) as? UserRatingCell else
        { return UITableViewCell() }

        guard let data = viewModel.dataForCellAtIndexPath(indexPath) else { return UITableViewCell() }

        cell.setupRatingCellWithData(data, indexPath: indexPath)
        cell.delegate = viewModel

        return cell
    }
}
