//
//  MakeAnOfferViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class MakeAnOfferViewController: UIViewController, UIActionSheetDelegate, UITextViewDelegate, UITextFieldDelegate {
    // outlets & buttons
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var commentsTextView: PlaceholderTextView!
    @IBOutlet weak var makeAnOfferButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // data
    var offerCurrency = CurrencyManager.sharedInstance.defaultCurrency
    var productUser: PFUser?
    var productObject: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // appearance
        setLetGoNavigationBarStyle(title: translate("make_an_offer"), includeBackArrow: true)
        self.currencyButton.layer.cornerRadius = 6.0
        self.activityIndicator.hidden = true
        
        // internationalization
        priceTextField.placeholder = translate("price")
        commentsTextView.placeholder = translate("comments_optional")
        makeAnOfferButton.setTitle(translate("send"), forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameters: [kLetGoTrackingParameterNameScreenName: "make-offer"])
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
        // safety checks
        let productPrice = priceTextField?.text.toInt()
        if productPrice == nil { showAutoFadingOutMessageAlert(translate("insert_valid_price")); return }
        var offerText = self.generateOfferText(productPrice!)
        if commentsTextView.text != nil && count(commentsTextView.text) > 0 { offerText += "\n\n" + commentsTextView.text! }

        // enable loading interface
        enableLoadingInterface()
        
        // check if we have some current conversation with the user
        ChatManager.sharedInstance.retrieveMyConversationWithUser(productUser!, aboutProduct: productObject!) { (success, conversation) -> Void in
            if success { // we have a conversation.
                // try to add the offer text first.
                ChatManager.sharedInstance.addTextMessage(offerText, toUser: self.productUser!, inConversation: conversation!, fromProduct: self.productObject!, completion: { (success, newlyCreatedMessageObject) -> Void in
                    if success { self.launchChatWithConversation(conversation!) }
                    else { self.disableLoadingInterface(); self.showAutoFadingOutMessageAlert(translate("error_making_offer")) }
                })
            } else { // we need to create a conversation and pass it.
                ChatManager.sharedInstance.createConversationWithUser(self.productUser!, aboutProduct: self.productObject!, completion: { (success, conversation) -> Void in
                    if success {
                        ChatManager.sharedInstance.addTextMessage(offerText, toUser: self.productUser!, inConversation: conversation!, fromProduct: self.productObject!, completion: { (success, newlyCreatedMessageObject) -> Void in
                            if success { self.launchChatWithConversation(conversation!) }
                            else { self.disableLoadingInterface(); self.showAutoFadingOutMessageAlert(translate("error_making_offer")) }
                        })
                    }
                    else { self.disableLoadingInterface(); self.showAutoFadingOutMessageAlert(translate("unable_start_conversation")) }
                })
            }
        }
    }
    
    func generateOfferText(price: Int) -> String {
        return translate("new_offer_of") + self.offerCurrency.formattedCurrency(Double(price), decimals: 0)
    }
    
    func launchChatWithConversation(conversation: PFObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let letgoConversation = LetGoConversation(parseConversationObject: conversation)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.disableLoadingInterface()
                if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier("productChatConversationVC") as? ChatViewController {
                    chatVC.letgoConversation = letgoConversation
                    if var controllers = self.navigationController?.viewControllers as? [UIViewController] {
                        controllers.removeLast()
                        controllers.append(chatVC)
                        self.navigationController!.viewControllers = controllers
                    } else { self.showAutoFadingOutMessageAlert(translate("unable_start_conversation")) }
                } else { self.showAutoFadingOutMessageAlert(translate("unable_start_conversation")) }
            })
        })
    }
    
    @IBAction func changeCurrency(sender: AnyObject) {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: translate("choose_currency"), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
            for currency in CurrencyManager.sharedInstance.allCurrencies() {
                alert.addAction(UIAlertAction(title: currency.currencyCode, style: .Default, handler: { (action) -> Void in
                    self.offerCurrency = currency
                    self.currencyButton.setTitle(currency.currencyCode, forState: .Normal)
                }))
            }
            self.presentViewController(alert, animated: true, completion: nil)
        } else { // ios7 fallback
            let actionSheet = UIActionSheet(title: translate("choose_currency"), delegate: self, cancelButtonTitle: translate("cancel"), destructiveButtonTitle: nil)
            for currency in CurrencyManager.sharedInstance.allCurrencies() {
                actionSheet.addButtonWithTitle(currency.currencyCode)
            }
            actionSheet.showInView(self.view)
        }
    }
    
    // iOS 7 Fallback for currency selection
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex > 0 { // 0 is cancel.
            let allCurrencies = CurrencyManager.sharedInstance.allCurrencies()
            let buttonCurrency = allCurrencies[buttonIndex - 1]
            self.offerCurrency = buttonCurrency
            self.currencyButton.setTitle(buttonCurrency.currencyCode, forState: .Normal)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UITextField/UITextView delegate methods for navigating through the fields.
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.commentsTextView.becomeFirstResponder()
        return false
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == text.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()) { return true }
        else { textView.resignFirstResponder(); return false }
    }

}


