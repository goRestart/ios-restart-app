//
//  ListingStatsView.swift
//  LetGo
//
//  Created by Dídac on 27/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ListingStatsView: UIView {

    enum Style {
        case light, dark

        var favIcon: UIImage {
            switch self {
            case .light: return #imageLiteral(resourceName: "ic_stats_favorite").withRenderingMode(.alwaysTemplate)
            case .dark: return #imageLiteral(resourceName: "ic_stats_favorite")
            }
        }
        var statsIcon: UIImage {
            switch self {
            case .light: return  #imageLiteral(resourceName: "ic_stats_views").withRenderingMode(.alwaysTemplate)
            case .dark: return  #imageLiteral(resourceName: "ic_stats_views")
            }
        }
        var timeIcon: UIImage {
            switch self {
            case .light: return  #imageLiteral(resourceName: "ic_stats_time").withRenderingMode(.alwaysTemplate)
            case .dark: return   #imageLiteral(resourceName: "ic_stats_time")
            }
        }
        var timePostedBorderWidth: CGFloat { return self == .light ? 0 : 1 }


        var iconTint: UIColor {
            switch self {
            case .light:
                return UIColor.grayDark
            case .dark: return UIColor.black.withAlphaComponent(0.5)
            }
        }
        var statBackground: UIColor {
            switch self {
            case .light:
                return UIColor.black.withAlphaComponent(0.05)
            case .dark: return UIColor.black.withAlphaComponent(0.5)
            }
        }
    }

    @IBOutlet weak var timePostedLeading: NSLayoutConstraint!
    @IBOutlet weak var favouriteStatsView: UIView!
    @IBOutlet weak var favouriteStatsLabel: UILabel!
    @IBOutlet weak var favouriteIcon: UIImageView!
    @IBOutlet weak var statsIcon: UIImageView!
    @IBOutlet weak var favouriteStatsWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var viewsStatsView: UIView!
    @IBOutlet weak var viewsStatsLabel: UILabel!
    @IBOutlet weak var viewsStatsWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var timePostedView: UIView!
    @IBOutlet weak var timePostedLabel: UILabel!
    @IBOutlet weak var timePostedIcon: UIImageView!
    @IBOutlet weak var timePostedWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var statsSeparationConstraint: NSLayoutConstraint!

    private let statsViewMaxWidth: CGFloat = 80
    private let statsSeparationWidth: CGFloat = 17
    private let maxStatsDisplayedCount = 999
    private let timeViewMinWidth: CGFloat = 55

    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 24.0) }

    private var style: Style = .dark {
        didSet { updateStyle() }
    }

    // MARK: - Lifecycle

    static func make() -> ListingStatsView? {
        let view = Bundle.main.loadNibNamed("ListingStatsView", owner: self, options: nil)?.first as? ListingStatsView
        view?.setupUI()
        view?.setupAccessibilityIds()
        return view
    }

    static func make(withStyle style: Style) -> ListingStatsView? {
        let view = make()
        view?.style = style
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    fileprivate func setupUI() {
        favouriteStatsView.layer.cornerRadius = 12
        viewsStatsView.layer.cornerRadius = 12
        timePostedView.layer.cornerRadius = 12

        statsSeparationConstraint.constant = 0

        favouriteStatsView.isHidden = true
        viewsStatsView.isHidden = true
        timePostedView.isHidden = true

        updateStyle()
    }
    
    private func setupAccessibilityIds() {       
        favouriteStatsView.set(accessibilityId: .listingStatsViewFavouriteStatsView)
        favouriteStatsLabel.set(accessibilityId: .listingStatsViewFavouriteStatsLabel)
        viewsStatsView.set(accessibilityId: .listingStatsViewFavouriteViewCountView)
        viewsStatsLabel.set(accessibilityId: .listingStatsViewFavouriteViewCountLabel)
        timePostedView.set(accessibilityId: .listingStatsViewFavouriteTimePostedView)
        timePostedLabel.set(accessibilityId: .listingStatsViewFavouriteTimePostedLabel)
    }

    private func updateStyle() {
        favouriteIcon.tintColor = style.iconTint
        favouriteStatsLabel.textColor = style.iconTint
        favouriteStatsView.backgroundColor = style.statBackground
        favouriteIcon.image = style.favIcon

        statsIcon.tintColor = style.iconTint
        viewsStatsLabel.textColor = style.iconTint
        viewsStatsView.backgroundColor = style.statBackground
        statsIcon.image = style.statsIcon

        timePostedIcon.tintColor = style.iconTint
        timePostedView.backgroundColor = style.statBackground
        timePostedView.layer.borderWidth = style.timePostedBorderWidth
    }

    func updateStatsWithInfo(_ viewsCount: Int, favouritesCount: Int, postedDate: Date?) {
        statsSeparationConstraint.constant = favouritesCount < Constants.minimumStatsCountToShow ? 0 : statsSeparationWidth

        favouriteStatsView.isHidden = favouritesCount < Constants.minimumStatsCountToShow
        viewsStatsView.isHidden = viewsCount < Constants.minimumStatsCountToShow

        favouriteStatsLabel.text = favouritesCount > maxStatsDisplayedCount ? "+999" : String(favouritesCount)
        favouriteStatsLabel.layer.add(CATransition(), forKey: kCATransition)

        viewsStatsLabel.text = viewsCount > maxStatsDisplayedCount ? "+999" : String(viewsCount)
        viewsStatsLabel.layer.add(CATransition(), forKey: kCATransition)

        setupPostedTimeViewWithDate(postedDate)
    }

    func setupPostedTimeViewWithDate(_ postedDate: Date?) {
        guard let postedDate = postedDate else {
            timePostedView.isHidden = true
            return
        }
        timePostedView.isHidden = false
        timePostedWidthConstraint.constant = timeViewMinWidth
        timePostedLabel.text = postedDate.relativeTimeString(true)

        timePostedView.layer.borderWidth = style.timePostedBorderWidth
        timePostedView.backgroundColor = style.statBackground

        if postedDate.isFromLast24h() {
            timePostedIcon.image = UIImage(named: "ic_new_stripe")
            timePostedLabel.textColor = UIColor.primaryColor
        } else {
            timePostedIcon.image = style.timeIcon
            timePostedIcon.tintColor = style.iconTint
            timePostedLabel.textColor = style.iconTint
        }
        timePostedView.layer.add(CATransition(), forKey: kCATransition)
    }
}
