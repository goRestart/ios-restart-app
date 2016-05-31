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

    @IBOutlet var statsSeparationConstraint: NSLayoutConstraint!

    private let statsViewMaxWidth: CGFloat = 80
    private let statsSeparationHeight: CGFloat = 17
    private let maxStatsDisplayedCount = 999


    // MARK: -Lifecycle

    static func productStatsViewWithInfo(viewsCount: Int, favouritesCount: Int) -> ProductStatsView? {

        let view = NSBundle.mainBundle().loadNibNamed("ProductStatsView", owner: self, options: nil).first as? ProductStatsView
        if let actualView = view {
            actualView.setupUI(viewsCount, favouritesCount: favouritesCount)
        }
        return view
    }

    func setupUI(viewsCount: Int, favouritesCount: Int) {
        favouriteStatsView.layer.cornerRadius = 12
        viewsStatsView.layer.cornerRadius = 12

        updateStatsWithInfo(viewsCount, favouritesCount: favouritesCount)
    }

    func updateStatsWithInfo(viewsCount: Int, favouritesCount: Int) {

        favouriteStatsWidthConstraint.constant = favouritesCount < Constants.minimumStatsCountToShow ? 0 : statsViewMaxWidth
        statsSeparationConstraint.constant = favouritesCount < Constants.minimumStatsCountToShow ? 0 : statsSeparationHeight
        viewsStatsWidthConstraint.constant = viewsCount < Constants.minimumStatsCountToShow ? 0 : statsViewMaxWidth

        favouriteStatsLabel.text = favouritesCount > maxStatsDisplayedCount ? "+999" : String(favouritesCount)
        viewsStatsLabel.text = viewsCount > maxStatsDisplayedCount ? "+999" : String(viewsCount)

        layoutSubviews()
    }
}
