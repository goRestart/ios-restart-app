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


    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        newSellViewModel = NewSellProductViewModel()
        super.init(viewModel: newSellViewModel)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setLetGoNavigationBarStyle(title: NSLocalizedString("sell_title", comment: "") ?? UIImage(named: "navbar_logo"))
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    internal override func sellCompleted() {
        super.sellCompleted()
        showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_ok", comment: "")) { () -> Void in
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
        case .Forbidden:
            // already logging out in viewModel
            message = NSLocalizedString("sell_send_error_uploading_product", comment: "")
        }
        self.showAutoFadingOutMessageAlert(message) { () -> Void in
            self.newSellViewModel.shouldEnableTracking()
        }
    }
    
    // button actions
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
