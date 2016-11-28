//
//  ProductListViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 25/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ProductsViewController: BaseViewController {

    private let viewModel: ProductsViewModel
    private let productList: ProductListView

    required init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
        self.productList = ProductListView(viewModel: viewModel.productListViewModel,
                                           featureFlags: viewModel.featureFlags, frame: CGRect.zero)
        super.init(viewModel: viewModel, nibName: "ProductsViewController")
        hidesBottomBarWhenPushed = false
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

        productList.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(productList)
        let views: [String : AnyObject] = ["list" : productList, "topGuide" : topLayoutGuide]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[list]-0-|",
            options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[list]-0-|",
            options: [], metrics: nil, views: views))
        addSubview(productList)

        productList.collectionViewContentInset.top = topBarHeight
    }
}
