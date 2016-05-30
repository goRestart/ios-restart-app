//
//  MakeAnOfferViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Result
import UIKit

class MakeAnOfferViewController: UIViewController, UIActionSheetDelegate, UITextFieldDelegate {
    // outlets & buttons
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var makeAnOfferButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // data
    var product: Product?

    override func viewDidLoad() {
        hidesBottomBarWhenPushed = true
        
        super.viewDidLoad()

        // appearance
        setLetGoNavigationBarStyle(LGLocalizedString.makeAnOfferTitle)
        // > set the product currency
        if let actualProduct = product {
            let currencyCode = actualProduct.currency.code
            let currencySymbol = Core.currencyHelper.currencySymbolWithCurrencyCode(currencyCode)
            currencyButton.setTitle(currencySymbol, forState: .Normal)
        }
        currencyButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        activityIndicator.hidden = true
        makeAnOfferButton.setPrimaryStyle()
        
        // internationalization
        priceTextField.placeholder = LGLocalizedString.makeAnOfferPriceFieldHint
        makeAnOfferButton.setTitle(LGLocalizedString.makeAnOfferSendButton, forState: .Normal)
        
        // setup
        if let price = product?.price {
            priceTextField.text = String.fromPriceDouble(price)
        }
        
        // show keyboard
        priceTextField.becomeFirstResponder()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }

    func enableLoadingInterface() {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        makeAnOfferButton.setTitle("", forState: .Normal)
    }
    
    func disableLoadingInterface() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        makeAnOfferButton.setTitle("send", forState: .Normal)
    }

    
    // MARK: - Button actions

    @IBAction func makeAnOffer(sender: AnyObject) {
        guard let product = product, productPriceStr = priceTextField.text else {
            showAutoFadingOutMessageAlert(LGLocalizedString.makeAnOfferSendErrorGeneric)
            return
        }
        enableLoadingInterface()

        let productPrice = productPriceStr.toPriceDouble()
        let offerText = generateOfferText(productPrice, currencyCode: product.currency.code)
        Core.oldChatRepository.sendOffer(offerText, product: product, recipient: product.user) {
            [weak self] (sendResult: Result<Message, RepositoryError>) -> Void in

            self?.disableLoadingInterface()

            guard let _ = sendResult.value else {
                self?.showAutoFadingOutMessageAlert(LGLocalizedString.makeAnOfferSendErrorGeneric)
                return
            }

            guard let chatVM = OldChatViewModel(product: product) else { return }
            chatVM.fromMakeOffer = true
            self?.openOldChatViewControllerWithChatVM(chatVM)

            // Tracking
            let offerEvent = TrackerEvent.productOffer(product, amount: productPrice)
            TrackerProxy.sharedInstance.trackEvent(offerEvent)

            let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: product.user,
                isQuickAnswer: .None, longPress: .False)
            TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
        }
    }

    func generateOfferText(price: Double, currencyCode: String) -> String {
        let formattedAmount = Core.currencyHelper.formattedAmountWithCurrencyCode(currencyCode, amount: price)
        return LGLocalizedString.makeAnOfferNewOfferMessage(formattedAmount)
    }
    
    func openOldChatViewControllerWithChatVM(chatVM: OldChatViewModel) {

        guard var controllers = navigationController?.viewControllers where controllers.last == self else {
            return
        }

        let chatVC = OldChatViewController(viewModel: chatVM)
        controllers.removeLast()
        controllers.append(chatVC)
        navigationController?.viewControllers = controllers
    }


    // MARK: UITextFieldDelegate Methods

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            return textField.shouldChangePriceInRange(range, replacementString: string)
    }
}


