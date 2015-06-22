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
        setLetGoNavigationBarStyle(title: translate("make_an_offer"))
        // > set the product currency
        if let actualProduct = product {
            let currencyCode = actualProduct.currencyCode ?? Constants.defaultCurrencyCode
            let currencySymbol = CurrencyHelper.sharedInstance.currencySymbolWithCurrencyCode(currencyCode)
            self.currencyButton.setTitle(currencySymbol, forState: .Normal)
        }
        self.currencyButton.layer.cornerRadius = 6.0
        self.activityIndicator.hidden = true
        
        // internationalization
        priceTextField.placeholder = translate("price")
        makeAnOfferButton.setTitle(translate("send"), forState: .Normal)
        
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
            if productPrice == nil { showAutoFadingOutMessageAlert(translate("insert_valid_price")); return }
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
                                    TrackingHelper.trackEvent(.ProductOffer, parameters: strongSelf.trackingParams)
                                    TrackingHelper.trackEvent(.UserMessageSent, parameters: strongSelf.trackingParams)
                                }
                                else {
                                    strongSelf.disableLoadingInterface()
                                    strongSelf.showAutoFadingOutMessageAlert(translate("error_making_offer"))
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
                                            TrackingHelper.trackEvent(.ProductOffer, parameters: strongSelf.trackingParams)
                                            TrackingHelper.trackEvent(.UserMessageSent, parameters: strongSelf.trackingParams)
                                        }
                                        else {
                                            strongSelf.disableLoadingInterface(); strongSelf.showAutoFadingOutMessageAlert(translate("error_making_offer"))
                                        }
                                    })
                                }
                                else { strongSelf.disableLoadingInterface(); strongSelf.showAutoFadingOutMessageAlert(translate("unable_start_conversation")) }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func generateOfferText(price: Int) -> String {
        let currencyCode = product?.currencyCode ?? Constants.defaultCurrencyCode
        let formattedAmount = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(currencyCode, amount: price)
        return translate("new_offer_of") + formattedAmount
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
                        strongSelf.showAutoFadingOutMessageAlert(translate("unable_start_conversation"))
                    }
                }
            })
        })
    }
    
    // MARK: - Tracking
    
    private var trackingParams: [TrackingParameter: AnyObject] {
        get {
            var properties: [TrackingParameter: AnyObject] = [:]
            if let actualProduct = product {
                if let city = actualProduct.postalAddress.city {
                    properties[.ProductCity] = city
                }
                if let country = actualProduct.postalAddress.countryCode {
                    properties[.ProductCountry] = country
                }
                if let zipCode = actualProduct.postalAddress.zipCode {
                    properties[.ProductZipCode] = zipCode
                }
                if let categoryId = actualProduct.categoryId as? Int {
                    properties[.CategoryId] = String(categoryId)
                }
                if let name = actualProduct.name {
                    properties[.ProductName] = name
                }
                if let productId = actualProduct.objectId {
                    properties[.ProductId] = productId
                }
            }
            if let user = product?.user {
                properties[.ItemType] = TrackingHelper.productTypeParamValue(user.isDummy)
            }
            if let otherUsr = product?.user, let otherUserId = otherUsr.objectId  {
                properties[.UserToId] = otherUserId
            }
            if let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId {
                properties[.UserId] = myUserId
            }
            
            return properties
        }
    }

}


