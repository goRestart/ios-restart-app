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

    static let cellReuseIdentifier = "UserRatingCell"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let viewModel: UserRatingListViewModel


    // MARK: Lifecycle

    convenience init(viewModel: UserRatingListViewModel) {
        self.init(viewModel: viewModel, nibName: "UserRatingListViewController")
    }

    required init(viewModel: UserRatingListViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
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


    // MARK: private methods

    private func setupUI() {
        let cellNib = UINib(nibName: UserRatingListViewController.cellReuseIdentifier, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: UserRatingListViewController.cellReuseIdentifier)
        tableView.hidden = true
        view.backgroundColor = UIColor.listBackgroundColor
    }
}


// MARK: UserRatingListViewModelDelegate

extension UserRatingListViewController: UserRatingListViewModelDelegate {

    func vmIsLoadingUserRatingsRequest(isLoading: Bool, firstPage: Bool) {
        if isLoading && firstPage {
            activityIndicator.startAnimating()
        }
    }

    func vmDidLoadUserRatings(ratings: [UserRating]) {
        activityIndicator.stopAnimating()
        tableView.hidden = false
        tableView.reloadData()
    }

    func vmDidFailLoadingUserRatings(firstPage: Bool) {
        activityIndicator.stopAnimating()
        if firstPage {
            vmShowAutoFadingMessage(LGLocalizedString.ratingListLoadingErrorMessage) { [weak self] in
                self?.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}

// MARK: UITableView Delegate

extension UserRatingListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ratings.count
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
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
