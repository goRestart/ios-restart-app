//
//  AppRatingView.swift
//  LetGo
//
//  Created by Dídac on 08/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

public class AppRatingView: UIView {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var bgButton: UIButton!
    
    @IBOutlet weak var doYouLoveLetgoLabel: UILabel!
    
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var loveItLabel: UILabel!
    @IBOutlet weak var ratUslabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var suggestView: UIView!
    @IBOutlet weak var needsImprLabel: UILabel!
    @IBOutlet weak var shareSuggestionsLabel: UILabel!
    @IBOutlet weak var suggestButton: UIButton!
    
    @IBOutlet weak var dontAskButton: UIButton!

    
    var contactBlock : ((UIViewController) -> Void)?
    
    
    public static func ratingView() -> AppRatingView? {
        return NSBundle.mainBundle().loadNibNamed("AppRatingView", owner: self, options: nil).first as? AppRatingView
    }

    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setupWithFrame(frame: CGRect, contactBlock: ((UIViewController) -> Void)?) {

        self.alpha = 0
        self.showWithFadeIn()
        
        self.frame = frame

        self.contactBlock = contactBlock

        mainView.layer.cornerRadius = 4
        rateView.layer.cornerRadius = 4
        suggestView.layer.cornerRadius = 4
        suggestView.layer.borderColor = StyleHelper.badgeBgColor.CGColor
        suggestView.layer.borderWidth = 2
        
        doYouLoveLetgoLabel.text = NSLocalizedString("rating_view_title_label", comment: "")
        
        loveItLabel.text = NSLocalizedString("rating_view_love_it_label", comment: "").uppercaseString
        ratUslabel.text = NSLocalizedString("rating_view_rate_us_label", comment: "")
        
        needsImprLabel.text = NSLocalizedString("rating_view_needs_improvements_label", comment: "").uppercaseString
        shareSuggestionsLabel.text = NSLocalizedString("rating_view_suggest_label", comment: "")
        
        dontAskButton.setTitle(NSLocalizedString("rating_view_dont_ask_again_button", comment: "").uppercaseString, forState: .Normal)
        
        let trackerEvent = TrackerEvent.appRatingStart()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

    }
    
    
    @IBAction func ratePressed(sender: AnyObject) {
        
        let trackerEvent = TrackerEvent.appRatingRate()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        let itunesURL = String(format: Constants.appStoreURL, arguments: [EnvironmentProxy.sharedInstance.appleAppId])
        UIApplication.sharedApplication().openURL(NSURL(string: itunesURL)!)
        self.closeWithFadeOut()
    }
    
    @IBAction func suggestPressed(sender: AnyObject) {
        
        let trackerEvent = TrackerEvent.appRatingSuggest()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        self.removeFromSuperview()
        let contactVC = ContactViewController()
        
        contactBlock?(contactVC)
    }
    
    @IBAction func dontAskPressed(sender: AnyObject) {
        
        let trackerEvent = TrackerEvent.appRatingDontAsk()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        self.closeWithFadeOut()
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.closeWithFadeOut()
    }
    

    func showWithFadeIn() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
        })
    }
    
    func closeWithFadeOut() {
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 0
        }) { (completed) -> Void in
            self.removeFromSuperview()
        }
        
    }

}
