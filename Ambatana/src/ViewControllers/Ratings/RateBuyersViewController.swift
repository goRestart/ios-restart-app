//
//  RateBuyersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class RateBuyersViewController: BaseViewController {

    fileprivate static let headerTopMargin: CGFloat = 64

    fileprivate let mainView: RateBuyersView
    fileprivate let viewModel: RateBuyersViewModel

    init(with viewModel: RateBuyersViewModel) {
        self.viewModel = viewModel
        self.mainView = RateBuyersView()
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self

    }
}


// MARK: - TableView delegate & datasource

extension RateBuyersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.buyersCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
//        guard let buyerCell = tableView.dequeueReusableCell(withIdentifier: PassiveBuyerCell.reusableID,
//                                                            for: indexPath) as? PassiveBuyerCell else { return UITableViewCell() }
//        let image = viewModel.buyerImageAtIndex(indexPath.row)
//        let name = viewModel.buyerNameAtIndex(indexPath.row)
//
//        buyerCell.setupWith(image, name: name, firstCell: indexPath.row == 0,
//                            lastCell: indexPath.row == viewModel.buyersCount - 1)
//        return buyerCell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scroll = scrollView.contentOffset.y + scrollView.contentInset.top
        mainView.headerTopMarginConstraint.constant = RateBuyersViewController.headerTopMargin - scroll
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedBuyerAt(index: indexPath.row)
    }
}
