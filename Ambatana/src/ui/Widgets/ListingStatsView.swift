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
                return UIColor.grayBackground
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
        
        favouriteStatsWidthConstraint.constant = 0
        statsSeparationConstraint.constant = 0
        viewsStatsWidthConstraint.constant = 0
        
        timePostedWidthConstraint.constant = 0

        favouriteIcon.image = #imageLiteral(resourceName: "ic_stats_favorite").withRenderingMode(.alwaysTemplate)
        statsIcon.image = #imageLiteral(resourceName: "ic_stats_views").withRenderingMode(.alwaysTemplate)
    }

    private func updateStyle() {
        favouriteIcon.tintColor = style.iconTint
        favouriteStatsView.backgroundColor = style.statBackground

        statsIcon.tintColor = style.iconTint
        viewsStatsView.backgroundColor = style.statBackground

        timePostedIcon.tintColor = style.iconTint
        timePostedView.backgroundColor = style.statBackground

        favouriteStatsLabel.textColor = style.iconTint
        viewsStatsLabel.textColor = style.iconTint
    }

    func updateStatsWithInfo(_ viewsCount: Int, favouritesCount: Int, postedDate: Date?) {

        favouriteStatsWidthConstraint.constant = favouritesCount < Constants.minimumStatsCountToShow ? 0 : statsViewMaxWidth
        statsSeparationConstraint.constant = favouritesCount < Constants.minimumStatsCountToShow ? 0 : statsSeparationWidth
        viewsStatsWidthConstraint.constant = viewsCount < Constants.minimumStatsCountToShow ? 0 : statsViewMaxWidth

        favouriteStatsLabel.text = favouritesCount > maxStatsDisplayedCount ? "+999" : String(favouritesCount)
        favouriteStatsLabel.layer.add(CATransition(), forKey: kCATransition)

        viewsStatsLabel.text = viewsCount > maxStatsDisplayedCount ? "+999" : String(viewsCount)
        viewsStatsLabel.layer.add(CATransition(), forKey: kCATransition)

        setupPostedTimeViewWithDate(postedDate)

        setNeedsLayout()
    }

    func setupPostedTimeViewWithDate(_ postedDate: Date?) {
        guard let postedDate = postedDate else {
            timePostedWidthConstraint.constant = 0
            return
        }
        timePostedWidthConstraint.constant = timeViewMinWidth
        timePostedLabel.text = postedDate.relativeTimeString(true)

        if postedDate.isFromLast24h() {
            timePostedIcon.image = UIImage(named: "ic_new_stripe")
            timePostedView.backgroundColor = UIColor.white
            timePostedLabel.textColor = UIColor.primaryColor
        } else {
            timePostedIcon.image = #imageLiteral(resourceName: "ic_stats_time").withRenderingMode(.alwaysTemplate)
            timePostedIcon.tintColor = style.iconTint
            timePostedView.backgroundColor = style.statBackground

            timePostedLabel.textColor = style.iconTint
        }
        timePostedView.layer.add(CATransition(), forKey: kCATransition)
    }
}
