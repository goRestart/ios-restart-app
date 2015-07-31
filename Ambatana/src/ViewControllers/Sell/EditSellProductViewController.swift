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
        
        sendButton.setTitle("_Update", forState: .Normal)
        categoryButton.setTitle(editViewModel.categoryName, forState: .Normal)
    }
    
    // MARK: - EditSellProductViewModelDelegate Methods
    
    func editSellProductViewModel(viewModel: EditSellProductViewModel, didDownloadImageAtIndex index: Int) {
        imageCollectionView.reloadData()
    }
    
    // MARK: - SellProductViewModelDelegate Methods

    override func sellProductViewModel(viewModel: SellProductViewModel, didFinishSavingProductWithResult result: Result<Product, ProductSaveServiceError>) {
        self.editViewModel.shouldDisableTracking()
        super.sellProductViewModel(viewModel, didFinishSavingProductWithResult: result)
        
        editViewModel.updateInfoOfPreviousVC()
        
        self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_ok", comment: "")) { () -> Void in
            self.navigationController?.popViewControllerAnimated(true)
            self.editViewModel.shouldEnableTracking()
        }
    }
    
    override func sellProductViewModel(viewModel: SellProductViewModel, didFailWithError error: ProductSaveServiceError) {
        self.editViewModel.shouldDisableTracking()
        super.sellProductViewModel(viewModel, didFailWithError: error)

        let message: String
        switch (error) {
        case .Network:
            message = NSLocalizedString("sell_send_error_uploading_product", comment: "")
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
        }
        self.showAutoFadingOutMessageAlert(message) { () -> Void in
            self.editViewModel.shouldEnableTracking()
        }
    }

}
