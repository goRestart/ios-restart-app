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
        self.listingList.isRelatedEnabled = false
        super.init(viewModel: viewModel, nibName: "SimpleListingsViewController")
        hidesBottomBarWhenPushed = true
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
        view.backgroundColor = UIColor.listBackgroundColor
        title = viewModel.title

        listingList.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listingList)
        let views: [String : Any] = ["list" : listingList, "topGuide" : topLayoutGuide]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[list]-0-|",
            options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[list]-0-|",
            options: [], metrics: nil, views: views))
        addSubview(listingList)

        listingList.collectionViewContentInset.top = topBarHeight
    }
}
