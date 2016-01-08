//
//  EditSellProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result


class EditSellProductViewController: BaseSellProductViewController, EditSellProductViewModelDelegate {

    
    private var editViewModel : EditSellProductViewModel
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(product: Product, updateDelegate: UpdateDetailInfoDelegate?) {
        self.init(viewModel: EditSellProductViewModel(product: product), updateDelegate: updateDelegate)
    }
    
    init(viewModel: EditSellProductViewModel, updateDelegate: UpdateDetailInfoDelegate?) {
        editViewModel = viewModel
        super.init(viewModel: editViewModel)
        
        editViewModel.editDelegate = self
        editViewModel.updateDetailDelegate = updateDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.setTitle(LGLocalizedString.editProductSendButton, forState: .Normal)
        categoryButton.setTitle(editViewModel.categoryName, forState: .Normal)
        
        self.setLetGoNavigationBarStyle(LGLocalizedString.editProductTitle)
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
    }

    
    // MARK: - SellProductViewModelDelegate Methods

    override func sellProductViewModel(viewModel: BaseSellProductViewModel, didFinishSavingProductWithResult
        result: ProductSaveServiceResult) {
            super.sellProductViewModel(viewModel, didFinishSavingProductWithResult: result)
            
            if let savedProduct = result.value {
                editViewModel.updateInfoOfPreviousVCWithProduct(savedProduct)
            }
    }
    
    internal override func sellCompleted() {
        super.sellCompleted()
        showAutoFadingOutMessageAlert(LGLocalizedString.editProductSendOk) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func sellProductViewModel(viewModel: BaseSellProductViewModel,
        didFailWithError error: ProductSaveServiceError) {
        
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
                message = LGLocalizedString.sellSendErrorInvalidDescriptionTooLong(Constants.productDescriptionMaxLength)
            case .NoCategory:
                message = LGLocalizedString.sellSendErrorInvalidCategory
            case .Forbidden:
                self.editViewModel.shouldDisableTracking()
                message = LGLocalizedString.logInErrorSendErrorGeneric
                completion = {
                    self.editViewModel.shouldEnableTracking()
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        SessionManager.sharedInstance.logout()
                    })
                }
            }
            self.showAutoFadingOutMessageAlert(message, completionBlock: completion)
    }


    // MARK: - Private methods

    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
