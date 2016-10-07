//
//  AppRatingView.swift
//  LetGo
//
//  Created by Dídac on 08/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol AppRatingViewDelegate {
    func appRatingViewDidSelectRating(rating: Int)
}

class AppRatingView: UIView {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bgButton: UIButton!
    @IBOutlet weak var ratUslabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet var stars: [UIButton]!
    
    var delegate: AppRatingViewDelegate?
    var ratingSource: EventParameterRatingSource?
    
    static func ratingView(source: EventParameterRatingSource) -> AppRatingView? {
        guard let view = NSBundle.mainBundle().loadNibNamed("AppRatingView", owner: self, options: nil)?.first
            as? AppRatingView else { return nil }
        view.ratingSource = source
        return view
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupWithFrame(frame: CGRect) {

        self.alpha = 0
        self.showWithFadeIn()
        
        self.frame = frame
        mainView.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        headerImageView.backgroundColor = UIColor.ratingBannerBackgroundColor
        mainTextLabel.text = LGLocalizedString.ratingViewTitleLabelUppercase
        ratUslabel.text = LGLocalizedString.ratingViewRateUsLabel
        dismissButton.setTitle(LGLocalizedString.ratingViewRemindLaterButton.uppercase, forState: .Normal)

        guard let source = ratingSource else { return }
        let trackerEvent = TrackerEvent.appRatingStart(source)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        setAccesibilityIds()
    }
    
    
    @IBAction func ratePressed(sender: AnyObject) {
        userRatesOrGivesFeedback()
        let trackerEvent = TrackerEvent.appRatingRate()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        closeWithFadeOut()
    }
    
    @IBAction func suggestPressed(sender: AnyObject) {
        userRatesOrGivesFeedback()
        let trackerEvent = TrackerEvent.appRatingSuggest()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        closeWithFadeOut()
    }

    @IBAction func dismissPressed(sender: AnyObject) {
        userWantsRemindLater()
        closeWithFadeOut()
    }

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
        delegate?.appRatingViewDidSelectRating(button.tag)
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


// MARK: - Accesibility

extension AppRatingView {
    func setAccesibilityIds() {
        if stars.count == 5 {
            stars[0].accessibilityId = .AppRatingStarButton1
            stars[1].accessibilityId = .AppRatingStarButton2
            stars[2].accessibilityId = .AppRatingStarButton3
            stars[3].accessibilityId = .AppRatingStarButton4
            stars[4].accessibilityId = .AppRatingStarButton5
        }
        bgButton.accessibilityId = .AppRatingBgButton
        dismissButton.accessibilityId = .AppRatingDismissButton
    }
}
