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
    
    required init?(coder: NSCoder) {
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
        
        self.setLetGoNavigationBarStyle(LGLocalizedString.editProductTitle)
    }
    
    // MARK: - EditSellProductViewModelDelegate Methods
    
    func editSellProductViewModel(viewModel: EditSellProductViewModel, didDownloadImageAtIndex index: Int) {
        imageCollectionView.reloadData()
    }
    
    // MARK: - SellProductViewModelDelegate Methods

    override func sellProductViewModel(viewModel: SellProductViewModel, didFinishSavingProductWithResult result: ProductSaveServiceResult) {
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
        
        super.sellProductViewModel(viewModel, didFailWithError: error)

        var completion: ((Void) -> Void)? = nil
        
        let message: String
        switch (error) {
        case .Network, .Internal:
            self.editViewModel.shouldDisableTracking()
            message = LGLocalizedString.editProductSendErrorUploadingProduct
            completion = {
                self.editViewModel.shouldEnableTracking()
            }
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
            self.editViewModel.shouldDisableTracking()
            message = LGLocalizedString.logInErrorSendErrorGeneric
            completion = {
                self.editViewModel.shouldEnableTracking()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    MyUserManager.sharedInstance.logout(nil)
                })
            }
        }
        self.showAutoFadingOutMessageAlert(message, completionBlock: completion)
    }
}
