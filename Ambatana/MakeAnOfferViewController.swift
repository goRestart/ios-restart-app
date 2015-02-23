//
//  MakeAnOfferViewController.swift
//  Ambatana
//
//  Created by Nacho on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class MakeAnOfferViewController: UIViewController {
    // outlets & buttons
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var commentsTextView: PlaceholderTextView!
    @IBOutlet weak var makeAnOfferButton: UIButton!
    
    // data
    var offerCurrency = Currency.defaultCurrency()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAmbatanaNavigationBarStyle(title: translate("make_an_offer"), includeBackArrow: true)
        
        // internationalization
        priceTextField.placeholder = translate("price")
        commentsTextView.placeholder = translate("comments_optional")
        makeAnOfferButton.setTitle(translate("send"), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    
    @IBAction func makeAnOffer(sender: AnyObject) {
    }
    
    @IBAction func changeCurrency(sender: AnyObject) {
        let alert = UIAlertController(title: translate("choose_currency"), message: nil, preferredStyle: .ActionSheet)
        for currency in Currency.allCurrencies() {
            alert.addAction(UIAlertAction(title: currency.rawValue, style: .Default, handler: { (action) -> Void in
                self.offerCurrency = currency
                self.currencyButton.setTitle(currency.symbol(), forState: .Normal)
            }))
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
