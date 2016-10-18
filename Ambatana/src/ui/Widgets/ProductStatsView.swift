//
//  ProductStatsView.swift
//  LetGo
//
//  Created by Dídac on 27/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ProductStatsView: UIView {

    @IBOutlet var favouriteStatsView: UIView!
    @IBOutlet var favouriteStatsLabel: UILabel!
    @IBOutlet var favouriteStatsWidthConstraint: NSLayoutConstraint!

    @IBOutlet var viewsStatsView: UIView!
    @IBOutlet var viewsStatsLabel: UILabel!
    @IBOutlet var viewsStatsWidthConstraint: NSLayoutConstraint!

    @IBOutlet var timePostedView: UIView!
    @IBOutlet var timePostedLabel: UILabel!
    @IBOutlet var timePostedIcon: UIImageView!
    @IBOutlet var timePostedWidthConstraint: NSLayoutConstraint!

    @IBOutlet var statsSeparationConstraint: NSLayoutConstraint!

    private let statsViewMaxWidth: CGFloat = 80
    private let statsSeparationWidth: CGFloat = 17
    private let maxStatsDisplayedCount = 999
    private let timeViewMinWidth: CGFloat = 55


    // MARK: -Lifecycle

    static func productStatsView() -> ProductStatsView? {
        let view = NSBundle.mainBundle().loadNibNamed("ProductStatsView", owner: self, options: nil)?.first as? ProductStatsView
        view?.setupUI()
        return view
    }

    func setupUI() {
        favouriteStatsView.layer.cornerRadius = 12
        viewsStatsView.layer.cornerRadius = 12
        timePostedView.layer.cornerRadius = 12
        
        favouriteStatsWidthConstraint.constant = 0
        statsSeparationConstraint.constant = 0
        viewsStatsWidthConstraint.constant = 0
        
        timePostedWidthConstraint.constant = 0
    }

    func updateStatsWithInfo(viewsCount: Int, favouritesCount: Int, postedDate: NSDate?) {

        favouriteStatsWidthConstraint.constant = favouritesCount < Constants.minimumStatsCountToShow ? 0 : statsViewMaxWidth
        statsSeparationConstraint.constant = favouritesCount < Constants.minimumStatsCountToShow ? 0 : statsSeparationWidth
        viewsStatsWidthConstraint.constant = viewsCount < Constants.minimumStatsCountToShow ? 0 : statsViewMaxWidth

        favouriteStatsLabel.text = favouritesCount > maxStatsDisplayedCount ? "+999" : String(favouritesCount)
        viewsStatsLabel.text = viewsCount > maxStatsDisplayedCount ? "+999" : String(viewsCount)

        setupPostedTimeViewWithDate(postedDate)

        layoutSubviews()
    }

    func setupPostedTimeViewWithDate(postedDate: NSDate?) {
        guard let postedDate = postedDate else {
            timePostedWidthConstraint.constant = 0
            return
        }
        timePostedWidthConstraint.constant = timeViewMinWidth
        timePostedLabel.text = postedDate.relativeTimeString(true)

        if postedDate.isFromLast24h() {
            timePostedIcon.image = UIImage(named: "ic_new_stripe")
            timePostedView.backgroundColor = UIColor.whiteColor()
            timePostedLabel.textColor = UIColor.primaryColor
        } else {
            timePostedIcon.image = UIImage(named: "ic_stats_time")
            timePostedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.54)
            timePostedLabel.textColor = UIColor.whiteColor()
        }
    }
}
