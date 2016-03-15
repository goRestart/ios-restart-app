//
//  MakeAnOfferViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
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
            let currencyCode = actualProduct.currency?.code ?? Constants.defaultCurrencyCode
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        guard let actualProduct = product, let productUser = product?.user,
            let myUser = Core.myUserRepository.myUser, let productPriceStr = priceTextField.text else {
                showAutoFadingOutMessageAlert(LGLocalizedString.makeAnOfferSendErrorGeneric)
                return
        }
        enableLoadingInterface()

        let productPrice = productPriceStr.toPriceDouble()
        let offerText = generateOfferText(productPrice)
        Core.chatRepository.sendOffer(offerText, product: actualProduct, recipient: productUser) {
            [weak self] (sendResult: Result<Message, RepositoryError>) -> Void in

            self?.disableLoadingInterface()

            guard let _ = sendResult.value else {
                self?.showAutoFadingOutMessageAlert(LGLocalizedString.makeAnOfferSendErrorGeneric)
                return
            }

            guard let chatVM = ChatViewModel(product: actualProduct) else { return }
            chatVM.fromMakeOffer = true
            self?.openChatViewControllerWithChatVM(chatVM)

            // Tracking
            let offerEvent = TrackerEvent.productOffer(actualProduct, user: myUser,
                amount: productPrice)
            TrackerProxy.sharedInstance.trackEvent(offerEvent)

            let messageSentEvent = TrackerEvent.userMessageSent(actualProduct, user: myUser)
            TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
        }
    }

    func generateOfferText(price: Double) -> String {
        let currencyCode = product?.currency?.code ?? Constants.defaultCurrencyCode
        let formattedAmount = Core.currencyHelper.formattedAmountWithCurrencyCode(currencyCode, amount: price)
        return LGLocalizedString.makeAnOfferNewOfferMessage(formattedAmount)
    }
    
    func openChatViewControllerWithChatVM(chatVM: ChatViewModel) {

        guard var controllers = navigationController?.viewControllers where controllers.last == self else {
            return
        }

        let chatVC = ChatViewController(viewModel: chatVM)
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


