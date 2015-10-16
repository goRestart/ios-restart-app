//
//  EditSellProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result


class EditSellProductViewController: SellProductViewController, EditSellProductViewModelDelegate {

    
    private var editViewModel : EditSellProductViewModel
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(product: Product, updateDelegate: UpdateDetailInfoDelegate?) {
        editViewModel = EditSellProductViewModel(product: product)
        super.init(viewModel: editViewModel)
        
        editViewModel.editDelegate = self
        editViewModel.updateDetailDelegate = updateDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editViewModel.loadPictures()
        
        sendButton.setTitle(LGLocalizedString.editProductSendButton, forState: .Normal)
        categoryButton.setTitle(editViewModel.categoryName, forState: .Normal)
        
        self.setLetGoNavigationBarStyle(title: LGLocalizedString.editProductTitle ?? UIImage(named: "navbar_logo"))
        var myBackButton = self.navigationItem.leftBarButtonItem

    }
    
    // MARK: - EditSellProductViewModelDelegate Methods
    
    func editSellProductViewModel(viewModel: EditSellProductViewModel, didDownloadImageAtIndex index: Int) {
        imageCollectionView.reloadData()
    }
    
    // MARK: - SellProductViewModelDelegate Methods

    override func sellProductViewModel(viewModel: SellProductViewModel, didFinishSavingProductWithResult result: Result<Product, ProductSaveServiceError>) {
        super.sellProductViewModel(viewModel, didFinishSavingProductWithResult: result)
        
        if let savedProduct = result.value {
            editViewModel.updateInfoOfPreviousVCWithProduct(savedProduct)
        }
    }
    
    internal override func sellCompleted() {
        super.sellCompleted()
        showAutoFadingOutMessageAlert(LGLocalizedString.editProductSendOk) { () -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func sellProductViewModel(viewModel: SellProductViewModel, didFailWithError error: ProductSaveServiceError) {
        self.editViewModel.shouldDisableTracking()
        super.sellProductViewModel(viewModel, didFailWithError: error)

        var completion = {
            self.editViewModel.shouldEnableTracking()
        }
        let message: String
        switch (error) {
        case .Network:
            message = LGLocalizedString.editProductSendErrorUploadingProduct
        case .Internal:
            message = LGLocalizedString.sellSendErrorUploadingProduct
        case .NoImages:
            message = LGLocalizedString.sellSendErrorInvalidImageCount
        case .NoTitle:
            message = LGLocalizedString.sellSendErrorInvalidTitle
        case .NoPrice:
            message = LGLocalizedString.sellSendErrorInvalidPrice
        case .NoDescription:
            message = LGLocalizedString.sellSendErrorInvalidDescription
        case .LongDescription:
            message = String(format: LGLocalizedString.sellSendErrorInvalidDescriptionTooLong, Constants.productDescriptionMaxLength)
        case .NoCategory:
            message = LGLocalizedString.sellSendErrorInvalidCategory
        case .Forbidden:
            message = LGLocalizedString.logInErrorSendErrorGeneric
            completion = {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    MyUserManager.sharedInstance.logout(nil)
                })
                self.editViewModel.shouldEnableTracking()
            }
        }
        self.showAutoFadingOutMessageAlert(message, completionBlock: completion)
    }

}
