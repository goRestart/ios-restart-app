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
        
        sendButton.setTitle(NSLocalizedString("edit_product_send_button", comment: ""), forState: .Normal)
        categoryButton.setTitle(editViewModel.categoryName, forState: .Normal)
        
        self.setLetGoNavigationBarStyle(NSLocalizedString("edit_product_title", comment: "") ?? UIImage(named: "navbar_logo"))
        _ = self.navigationItem.leftBarButtonItem

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
        showAutoFadingOutMessageAlert(NSLocalizedString("edit_product_send_ok", comment: "")) { () -> Void in
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
            message = NSLocalizedString("edit_product_send_error_uploading_product", comment: "")
        case .Internal:
            message = NSLocalizedString("sell_send_error_uploading_product", comment: "")
        case .NoImages:
            message = NSLocalizedString("sell_send_error_invalid_image_count", comment: "")
        case .NoTitle:
            message = NSLocalizedString("sell_send_error_invalid_title", comment: "")
        case .NoPrice:
            message = NSLocalizedString("sell_send_error_invalid_price", comment: "")
        case .NoDescription:
            message = NSLocalizedString("sell_send_error_invalid_description", comment: "")
        case .LongDescription:
            message = String(format: NSLocalizedString("sell_send_error_invalid_description_too_long", comment: ""), Constants.productDescriptionMaxLength)
        case .NoCategory:
            message = NSLocalizedString("sell_send_error_invalid_category", comment: "")
        case .Forbidden:
            message = NSLocalizedString("log_in_error_send_error_generic", comment: "")
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
