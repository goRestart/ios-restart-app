//
//  EditSellProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class EditSellProductViewController: SellProductViewController, EditSellProductViewModelDelegate {

    
    override init() {
        super.init()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(product: Product) {
        self.init()
        viewModel = EditSellProductViewModel(product: product)
        self.viewModel.delegate = self
        self.viewModel.editDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.setTitle("_Update", forState: .Normal)
        categoryButton.setTitle(viewModel.categoryName, forState: .Normal)
    }
    
    // MARK: - EditSellProductViewModelDelegate Methods
    
    func editSellProductViewModel(viewModel: EditSellProductViewModel, didDownloadImageAtIndex index: Int) {
//        imageCollectionView.reloadData()
        imageCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
    }

    
}
