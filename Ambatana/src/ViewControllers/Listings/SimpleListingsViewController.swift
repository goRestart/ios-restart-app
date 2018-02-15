//
//  ListingListViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 25/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class SimpleListingsViewController: BaseViewController {

    private let viewModel: SimpleListingsViewModel
    private let listingList: ListingListView

    required init(viewModel: SimpleListingsViewModel) {
        self.viewModel = viewModel
        self.listingList = ListingListView(viewModel: viewModel.listingListViewModel,
                                           featureFlags: viewModel.featureFlags, frame: CGRect.zero)
        super.init(viewModel: viewModel, nibName: "SimpleListingsViewController")
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }


    // MARK: - Private

    private func setupUI() {
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.listBackgroundColor
        title = viewModel.title

        view.addSubview(listingList)
        addSubview(listingList)
    }
    
    private func setupConstraints() {
        listingList.translatesAutoresizingMaskIntoConstraints = false
        listingList.layout(with: view).fill()
    }
}
