//
//  MakeAnOfferViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
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
        
        if let actualProduct = product, let productUser = product?.user {
            
            // safety checks
            let productPrice = priceTextField?.text.toInt()
            if productPrice == nil { showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_invalid_price", comment: "") , time: 3.5); return }
            var offerText = self.generateOfferText(productPrice!)
            
            // enable loading interface
            enableLoadingInterface()
            
            // check if we have some current conversation with the user
            ChatManager.sharedInstance.retrieveMyConversationWithUser(productUser, aboutProduct: actualProduct) { [weak self] (success, conversation) -> Void in
                if let strongSelf = self {
                    if success { // we have a conversation.
                        // try to add the offer text first.
                        ChatManager.sharedInstance.addTextMessage(offerText, toUser: productUser, inConversation: conversation!, fromProduct: actualProduct, isOffer: true, completion: { [weak self] (success, newlyCreatedMessageObject) -> Void in
                            if let strongSelf = self {
                                if success {
                                    strongSelf.launchChatWithConversation(conversation!)
                                    
                                    // Tracking
                                    let myUser = MyUserManager.sharedInstance.myUser()
                                    let offerEvent = TrackerEvent.productOffer(actualProduct, user: myUser, amount: Double(productPrice!))
                                    TrackerProxy.sharedInstance.trackEvent(offerEvent)
                                    
                                    let messageSentEvent = TrackerEvent.userMessageSent(actualProduct, user: myUser)
                                    TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
                                }
                                else {
                                    strongSelf.disableLoadingInterface()
                                    strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
                                }
                            }
                        })
                    }
                    else { // we need to create a conversation and pass it.
                        ChatManager.sharedInstance.createConversationWithUser(productUser, aboutProduct: actualProduct, completion: { [weak self] (success, conversation) -> Void in
                            if let strongSelf = self {
                                if success {
                                    ChatManager.sharedInstance.addTextMessage(offerText, toUser: productUser, inConversation: conversation!, fromProduct: actualProduct, isOffer: true, completion: { (success, newlyCreatedMessageObject) -> Void in
                                        if success {
                                            strongSelf.launchChatWithConversation(conversation!)
                                            
                                            // Tracking
                                            let myUser = MyUserManager.sharedInstance.myUser()
                                            let offerEvent = TrackerEvent.productOffer(actualProduct, user: myUser, amount: Double(productPrice!))
                                            TrackerProxy.sharedInstance.trackEvent(offerEvent)
                                            
                                            let messageSentEvent = TrackerEvent.userMessageSent(actualProduct, user: myUser)
                                            TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
                                        }
                                        else {
                                            strongSelf.disableLoadingInterface(); strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
                                        }
                                    })
                                }
                                else {
                                    strongSelf.disableLoadingInterface()
                                    strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func generateOfferText(price: Int) -> String {
        let currencyCode = product?.currency?.code ?? Constants.defaultCurrencyCode
        let formattedAmount = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(currencyCode, amount: price)
        return String(format: NSLocalizedString("make_an_offer_new_offer_message", comment: ""), formattedAmount)
    }
    
    func launchChatWithConversation(conversation: PFObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let letgoConversation = LetGoConversation(parseConversationObject: conversation)
            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                if let strongSelf = self {
                    strongSelf.disableLoadingInterface()
                    let chatVC = ChatViewController()
                    chatVC.letgoConversation = letgoConversation
                    
                    if var controllers = strongSelf.navigationController?.viewControllers as? [UIViewController] {
                        controllers.removeLast()
                        controllers.append(chatVC)
                        strongSelf.navigationController!.viewControllers = controllers
                    }
                    else {
                        strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("make_an_offer_send_error_generic", comment: ""))
                    }
                }
            })
        })
    }
}


