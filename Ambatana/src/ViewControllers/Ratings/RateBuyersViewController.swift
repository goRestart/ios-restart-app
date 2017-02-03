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
        mainView.tableView.rowHeight = PossibleBuyerCell.cellHeight

        let cellNib = UINib(nibName: PossibleBuyerCell.reusableID, bundle: nil)
        mainView.tableView.register(cellNib, forCellReuseIdentifier: PossibleBuyerCell.reusableID)
    }
}


// MARK: - TableView delegate & datasource

extension RateBuyersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.buyersCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
        guard let buyerCell = tableView.dequeueReusableCell(withIdentifier: PossibleBuyerCell.reusableID,
                                                            for: indexPath) as? PossibleBuyerCell else { return UITableViewCell() }
        let image = viewModel.imageAt(index: indexPath.row)
        let name = viewModel.nameAt(index: indexPath.row)

        buyerCell.setupWith(image, name: name, firstCell: indexPath.row == 0,
                            lastCell: indexPath.row == viewModel.buyersCount - 1)
        return buyerCell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scroll = scrollView.contentOffset.y + scrollView.contentInset.top
        mainView.headerTopMarginConstraint.constant = RateBuyersViewController.headerTopMargin - scroll
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedBuyerAt(index: indexPath.row)
    }
}
