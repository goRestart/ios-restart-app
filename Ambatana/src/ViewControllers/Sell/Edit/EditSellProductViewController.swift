//
//  EditSellProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result


class EditSellProductViewController: BaseSellProductViewController {
    
    private var editViewModel: EditSellProductViewModel
    weak var sellDelegate: SellProductViewControllerDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: EditSellProductViewModel, updateDelegate: UpdateDetailInfoDelegate?) {
        editViewModel = viewModel
        super.init(viewModel: editViewModel)
        
        editViewModel.updateDetailDelegate = updateDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.setTitle(LGLocalizedString.editProductSendButton, forState: .Normal)
        categoryButton.setTitle(editViewModel.categoryName, forState: .Normal)
        
        self.setLetGoNavigationBarStyle(LGLocalizedString.editProductTitle)
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain,
            target: self, action: #selector(EditSellProductViewController.closeButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton;
    }

    
    // MARK: - SellProductViewModelDelegate Methods

    override func sellProductViewModel(viewModel: BaseSellProductViewModel, didFinishSavingProductWithResult
        result: ProductResult) {
            super.sellProductViewModel(viewModel, didFinishSavingProductWithResult: result)
            
            if let savedProduct = result.value {
                editViewModel.updateInfoOfPreviousVCWithProduct(savedProduct)
            }
    }
    
    internal override func sellCompleted() {
        super.sellCompleted()
        showAutoFadingOutMessageAlert(LGLocalizedString.editProductSendOk) { [weak self] in
            guard let strongSelf = self else { return }
            let action: () -> () = { strongSelf.editViewModel.notifyPreviousVCEditCompleted() }
            strongSelf.dismiss(action)
        }
    }
    
    override func sellProductViewModel(viewModel: BaseSellProductViewModel,
        didFailWithError error: ProductCreateValidationError) {
        
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
            }
            self.showAutoFadingOutMessageAlert(message, completion: completion)
    }


    // MARK: - Private methods

    dynamic func closeButtonPressed() {
        dismiss()
    }

    private func dismiss(action: (() -> ())? = nil) {
        self.dismissViewControllerAnimated(true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sellDelegate?.sellProductViewController(strongSelf, didCompleteSell: true,
                                            withPromoteProductViewModel: strongSelf.editViewModel.promoteProductVM)
            action?()
        }
    }
}
