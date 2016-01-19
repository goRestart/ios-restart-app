//
//  NewSellProductViewController.swift
//  LetGo
//
//  Created by Dídac on 16/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result

class NewSellProductViewController: BaseSellProductViewController {

    weak var completedSellDelegate: SellProductViewControllerDelegate?

    private var newSellViewModel : NewSellProductViewModel


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        newSellViewModel = NewSellProductViewModel()
        super.init(viewModel: newSellViewModel)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setLetGoNavigationBarStyle(LGLocalizedString.sellTitle)
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    internal override func sellCompleted() {
        super.sellCompleted()
        showAutoFadingOutMessageAlert(LGLocalizedString.sellSendOk) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: { [weak self] in
                if let strongSelf = self {
                    strongSelf.completedSellDelegate?.sellProductViewController(self, didCompleteSell: true)
                }
                })
        }
    }
    
    override func sellProductViewModel(viewModel: BaseSellProductViewModel, didFailWithError
        error: ProductCreateValidationError) {
            
            super.sellProductViewModel(viewModel, didFailWithError: error)
            
            var completion: ((Void)->Void)? = nil
            
            let message: String
            switch (error) {
            case .Network, .Internal:
                self.newSellViewModel.shouldDisableTracking()
                message = LGLocalizedString.sellSendErrorUploadingProduct
                completion = {
                    self.newSellViewModel.shouldEnableTracking()
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
            self.showAutoFadingOutMessageAlert(message, completionBlock: completion)
    }
    
    // button actions
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
