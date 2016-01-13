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
            let currencySymbol = CurrencyHelper.sharedInstance.currencySymbolWithCurrencyCode(currencyCode)
            self.currencyButton.setTitle(currencySymbol, forState: .Normal)
        }
        self.currencyButton.layer.cornerRadius = 6.0
        self.activityIndicator.hidden = true
        
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
        if let actualProduct = product, let productUser = product?.user,
            let myUser = MyUserRepository.sharedInstance.myUser, let productPriceStr = priceTextField.text {
            let productPrice = productPriceStr.toPriceDouble()

            enableLoadingInterface()

            // 1. Send the offer
            let offerText = generateOfferText(productPrice)
            ChatRepository.sharedInstance.sendOffer(offerText, product: actualProduct, recipient: productUser) {
                [weak self] (sendResult: Result<Message, RepositoryError>) -> Void in
                if let strongSelf = self {

                    // Success
                    if let _ = sendResult.value {

                        // 2. Retrieve the chat
                        ChatRepository.sharedInstance.retrieveChatWithProduct(actualProduct, buyer: myUser) {
                            [weak self] (retrieveResult: Result<Chat, RepositoryError>) -> Void in
                            if let strongSelf2 = self {

                                // Not loading
                                strongSelf2.disableLoadingInterface()
                                
                                // Success
                                if let chat = retrieveResult.value {
                                    
                                    // 3. Open chat
                                    strongSelf2.openChatViewControllerWithChat(chat)
                                    
                                    // Tracking
                                    let offerEvent = TrackerEvent.productOffer(actualProduct, user: myUser,
                                        amount: productPrice)
                                    TrackerProxy.sharedInstance.trackEvent(offerEvent)
                                    
                                    let messageSentEvent = TrackerEvent.userMessageSent(actualProduct, user: myUser)
                                    TrackerProxy.sharedInstance.trackEvent(messageSentEvent)

                                } else if let _ = retrieveResult.error {
                                        strongSelf2.showAutoFadingOutMessageAlert(
                                            LGLocalizedString.makeAnOfferSendErrorGeneric)
                                }
                            }
                        }
                    } else {
                        strongSelf.disableLoadingInterface()
                        
                        if let _ = sendResult.error {
                            strongSelf.showAutoFadingOutMessageAlert(LGLocalizedString.makeAnOfferSendErrorGeneric)
                        }
                    }
                }
            }
        } else {
            showAutoFadingOutMessageAlert(LGLocalizedString.makeAnOfferSendErrorInvalidPrice , time: 3.5);
        }
    }
    
    func generateOfferText(price: Double) -> String {
        let currencyCode = product?.currency?.code ?? Constants.defaultCurrencyCode
        let formattedAmount = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(currencyCode, amount: price)
        return LGLocalizedString.makeAnOfferNewOfferMessage(formattedAmount)
    }
    
    func openChatViewControllerWithChat(chat: Chat) {
        if let chatViewModel = ChatViewModel(chat: chat), var controllers = navigationController?.viewControllers {
            chatViewModel.fromMakeOffer = true
            let chatVC = ChatViewController(viewModel: chatViewModel)
            controllers.removeLast()
            controllers.append(chatVC)
            navigationController?.viewControllers = controllers
        } else {
            showAutoFadingOutMessageAlert(LGLocalizedString.makeAnOfferSendErrorGeneric)
        }
    }


    // MARK: UITextFieldDelegate Methods

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            return textField.shouldChangePriceInRange(range, replacementString: string)
    }
}


