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


@objc protocol NewSellProductViewControllerDelegate {
    optional func sellProductViewController(sellVC: NewSellProductViewController?, didCompleteSell successfully: Bool)
}

class NewSellProductViewController: SellProductViewController {

    var completedSellDelegate: NewSellProductViewControllerDelegate?

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
                    strongSelf.completedSellDelegate?.sellProductViewController?(self, didCompleteSell: true)
                }
            })
        }
    }
    
    override func sellProductViewModel(viewModel: SellProductViewModel, didFailWithError error: ProductSaveServiceError) {
        self.newSellViewModel.shouldDisableTracking()
        super.sellProductViewModel(viewModel, didFailWithError: error)
        
        var completion = {
            self.newSellViewModel.shouldEnableTracking()
        }
        let message: String
        switch (error) {
        case .Network:
            message = LGLocalizedString.sellSendErrorUploadingProduct
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
                self.newSellViewModel.shouldEnableTracking()
            }
        }
        self.showAutoFadingOutMessageAlert(message, completionBlock: completion)
    }
    
    // button actions
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
