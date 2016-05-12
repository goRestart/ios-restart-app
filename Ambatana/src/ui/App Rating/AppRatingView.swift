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
    
    @IBOutlet weak var dismissButton: UIButton!

    var ratingSource: EventParameterRatingSource?
    var contactBlock : ((UIViewController) -> Void)?
    
    
    public static func ratingView(source: EventParameterRatingSource) -> AppRatingView? {
        guard let view = NSBundle.mainBundle().loadNibNamed("AppRatingView", owner: self, options: nil).first
            as? AppRatingView else { return nil }
        view.ratingSource = source
        return view
    }
    
    public required init?(coder aDecoder: NSCoder) {
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
        
        doYouLoveLetgoLabel.text = LGLocalizedString.ratingViewTitleLabel
        
        loveItLabel.text = LGLocalizedString.ratingViewLoveItLabel.uppercase
        ratUslabel.text = LGLocalizedString.ratingViewRateUsLabel
        
        needsImprLabel.text = LGLocalizedString.ratingViewNeedsImprovementsLabel.uppercase
        shareSuggestionsLabel.text = LGLocalizedString.ratingViewSuggestLabel
        
        dismissButton.setTitle(LGLocalizedString.ratingViewRemindLaterButton.uppercase, forState: .Normal)

        guard let source = ratingSource else { return }
        let trackerEvent = TrackerEvent.appRatingStart(source)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    
    @IBAction func ratePressed(sender: AnyObject) {
        userRatesOrGivesFeedback()

        let trackerEvent = TrackerEvent.appRatingRate()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        UIApplication.sharedApplication().openURL(NSURL(string: Constants.appStoreURL)!)
        closeWithFadeOut()
    }
    
    @IBAction func suggestPressed(sender: AnyObject) {
        userRatesOrGivesFeedback()

        let trackerEvent = TrackerEvent.appRatingSuggest()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        self.removeFromSuperview()
        let contactVC = ContactViewController()
        
        contactBlock?(contactVC)
    }

    // dismiss Button
    @IBAction func dismissPressed(sender: AnyObject) {
        userWantsRemindLater()
        closeWithFadeOut()
    }

    // bgButton
    @IBAction func closePressed(sender: AnyObject) {
        userWantsRemindLater()
        closeWithFadeOut()
    }


    // MARK: Private Methods

    private func showWithFadeIn() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
        })
    }
    
    private func closeWithFadeOut() {
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 0
        }) { (completed) -> Void in
            self.removeFromSuperview()
        }
    }

    private func userRatesOrGivesFeedback() {
        RatingManager.sharedInstance.userDidRate()
    }

    private func userWantsRemindLater() {
        let event = TrackerEvent.appRatingRemindMeLater()
        TrackerProxy.sharedInstance.trackEvent(event)

        let sourceIsBanner = ratingSource == .Banner
        RatingManager.sharedInstance.userDidRemindLater(sourceIsBanner: sourceIsBanner)
    }
}
