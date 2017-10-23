//
//  AppRatingView.swift
//  LetGo
//
//  Created by Dídac on 08/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol AppRatingViewDelegate: class {
    func appRatingViewDidSelectRating(_ rating: Int)
}

class AppRatingView: UIView {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bgButton: UIButton!
    @IBOutlet weak var ratUslabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet var stars: [UIButton]!
    
    weak var delegate: AppRatingViewDelegate?
    var ratingSource: EventParameterRatingSource?
    
    static func ratingView(_ source: EventParameterRatingSource) -> AppRatingView? {
        guard let view = Bundle.main.loadNibNamed("AppRatingView", owner: self, options: nil)?.first
            as? AppRatingView else { return nil }
        view.ratingSource = source
        return view
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupWithFrame(_ frame: CGRect) {

        self.alpha = 0
        self.showWithFadeIn()
        
        self.frame = frame
        mainView.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        headerImageView.backgroundColor = UIColor.ratingViewBackgroundColor
        mainTextLabel.text = LGLocalizedString.ratingViewTitleLabelUppercase
        ratUslabel.text = LGLocalizedString.ratingViewRateUsLabel
        dismissButton.setTitle(LGLocalizedString.ratingViewRemindLaterButton.uppercase, for: .normal)

        setAccesibilityIds()
    }

    
    @IBAction func ratePressed(_ sender: AnyObject) {
        userRatesOrGivesFeedback()
        if let _ = (sender as? UIButton)?.tag {
            let trackerEvent = TrackerEvent.appRatingRate(nil)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        }
        closeWithFadeOut()
    }
    
    @IBAction func suggestPressed(_ sender: AnyObject) {
        userRatesOrGivesFeedback()
        let trackerEvent = TrackerEvent.appRatingSuggest()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        closeWithFadeOut()
    }

    @IBAction func dismissPressed(_ sender: AnyObject) {
        userWantsRemindLater()
        closeWithFadeOut()
    }

    @IBAction func closePressed(_ sender: AnyObject) {
        userWantsRemindLater()
        closeWithFadeOut()
    }

    @IBAction func starHighlighted(_ sender: AnyObject) {
        guard let tag = (sender as? UIButton)?.tag else { return }
        stars.forEach{$0.isHighlighted = ($0.tag <= tag)}
    }
    
    @IBAction func starSelected(_ sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        button.isSelected = true
        delegate?.appRatingViewDidSelectRating(button.tag)
        ratePressed(sender)
    }
    
    
    // MARK: Private Methods

    private func showWithFadeIn() {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alpha = 1
        })
    }
    
    private func closeWithFadeOut() {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alpha = 0
        }, completion: { (completed) -> Void in
            self.removeFromSuperview()
        }) 
    }

    private func userRatesOrGivesFeedback() {
        LGRatingManager.sharedInstance.userDidRate()
    }

    private func userWantsRemindLater() {
        let event = TrackerEvent.appRatingRemindMeLater()
        TrackerProxy.sharedInstance.trackEvent(event)
        LGRatingManager.sharedInstance.userDidRemindLater()
    }
}


// MARK: - Accesibility

extension AppRatingView {
    func setAccesibilityIds() {
        if stars.count == 5 {
            stars[0].accessibilityId = .appRatingStarButton1
            stars[1].accessibilityId = .appRatingStarButton2
            stars[2].accessibilityId = .appRatingStarButton3
            stars[3].accessibilityId = .appRatingStarButton4
            stars[4].accessibilityId = .appRatingStarButton5
        }
        bgButton.accessibilityId = .appRatingBgButton
        dismissButton.accessibilityId = .appRatingDismissButton
    }
}
