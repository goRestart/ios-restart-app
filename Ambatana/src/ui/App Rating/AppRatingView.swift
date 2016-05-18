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
    @IBOutlet weak var ratUslabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var headerImageView: UIImageView!

    @IBOutlet var stars: [UIButton]!
    
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

        mainView.layer.cornerRadius = StyleHelper.ratingCornerRadius

        headerImageView.backgroundColor = StyleHelper.ratingBannerBackgroundColor
        
        doYouLoveLetgoLabel.text = LGLocalizedString.ratingViewTitleLabel
        
        ratUslabel.text = LGLocalizedString.ratingViewRateUsLabel
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

    @IBAction func starHighlighted(sender: AnyObject) {
        guard let tag = (sender as? UIButton)?.tag else { return }
        stars.forEach{$0.highlighted = ($0.tag <= tag)}
    }
    
    @IBAction func starSelected(sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        button.selected = true
        button.tag <= 3 ? suggestPressed(sender) : ratePressed(sender)
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
