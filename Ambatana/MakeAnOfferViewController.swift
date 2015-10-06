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

class MakeAnOfferViewController: UIViewController, UIActionSheetDelegate, UITextViewDelegate {
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
        setLetGoNavigationBarStyle(title: NSLocalizedString("make_an_offer_title", comment: ""))
        // > set the product currency
        if let actualProduct = product {
            let currencyCode = actualProduct.currency?.code ?? Constants.defaultCurrencyCode
            let currencySymbol = CurrencyHelper.sharedInstance.currencySymbolWithCurrencyCode(currencyCode)
            self.currencyButton.setTitle(currencySymbol, forState: .Normal)
        }
        self.currencyButton.layer.cornerRadius = 6.0
        self.activityIndicator.hidden = true
        
        // internationalization
        priceTextField.placeholder = NSLocalizedString("make_an_offer_price_field_hint", comment: "")
        makeAnOfferButton.setTitle(NSLocalizedString("make_an_offer_send_button", comment: ""), forState: .Normal)
        
        // setup
        priceTextField.text = product?.price?.stringValue ?? ""
        
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
        if let actualProduct = product, let productUser = product?.user, let myUser = MyUserManager.sharedInstance.myUser(), let productPrice = priceTextField?.text.toInt() {
            
            // Loading
            enableLoadingInterface()

            // 1. Send the offer
            var offerText = generateOfferText(productPrice)
            ChatManager.sharedInstance.sendOffer(offerText, product: actualProduct, recipient: productUser) { [weak self] (sendResult: Result<Message, ChatSendMessageServiceError>) -> Void in
                if let strongSelf = self {

                    // Success
                    if let success = sendResult.value {

                        // 2. Retrieve the chat
                        ChatManager.sharedInstance.retrieveChatWithProduct(actualProduct, buyer: myUser) { [weak self] (retrieveResult: Result<Chat, ChatRetrieveServiceError>) -> Void in
                            if let strongSelf2 = self {

                                // Not loading
                                strongSelf2.disableLoadingInterface()
                                
                                // Success
                                if let chat = retrieveResult.value {
                                    
                                    // 3. Open chat
                                    strongSelf2.openChatViewControllerWithChat(chat)
                                    
                                    // Tracking
                                    let myUser = MyUserManager.sharedInstance.myUser()
                                    let offerEvent = TrackerEvent.productOffer(actualProduct, user: myUser, amount: Double(productPrice))
                                    TrackerProxy.sharedInstance.trackEvent(offerEvent)
                                    
                                    let messageSentEvent = TrackerEvent.userMessageSent(actualProduct, user: myUser)
                                    TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
                                }
                                // Error
                                else {
                                    
                                    if let actualError = retrieveResult.error {
                                        if actualError == .Forbidden {
                                            strongSelf2.showAutoFadingOutMessageAlert(NSLocalizedString("log_in_error_send_error_generic", comment: ""), completionBlock: { (completion) -> Void in
                                                MyUserManager.sharedInstance.logout(nil)
                                            })
                                        } else {
                                            strongSelf2.showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Error
                    else {
                        strongSelf.disableLoadingInterface()
                        
                        if let actualError = sendResult.error {
                            if actualError == .Forbidden {
                                strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("log_in_error_send_error_generic", comment: ""), completionBlock: { (completion) -> Void in
                                    MyUserManager.sharedInstance.logout(nil)
                                })
                            } else {
                                strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
                            }
                        }
                    }
                }
            }
        }
        else {
            showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_invalid_price", comment: "") , time: 3.5);
        }
    }
    
    func generateOfferText(price: Int) -> String {
        let currencyCode = product?.currency?.code ?? Constants.defaultCurrencyCode
        let formattedAmount = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(currencyCode, amount: price)
        return String(format: NSLocalizedString("make_an_offer_new_offer_message", comment: ""), formattedAmount)
    }
    
    func openChatViewControllerWithChat(chat: Chat) {
        if let chatVC = ChatViewController(chat: chat), var controllers = navigationController?.viewControllers as? [UIViewController] {
            controllers.removeLast()
            controllers.append(chatVC)
            navigationController?.viewControllers = controllers
        }
        else {
            showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
        }
        
    }
    
    func launchChatVC(chat: Chat) {
        if let chatVC = ChatViewController(chat: chat), var controllers = navigationController?.viewControllers as? [UIViewController] {
            controllers.removeLast()
            controllers.append(chatVC)
            navigationController?.viewControllers = controllers
        }
        else {
            showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
        }
    }
}


