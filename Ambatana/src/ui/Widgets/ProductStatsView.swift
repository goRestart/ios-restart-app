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

        favouriteStatsWidthConstraint.constant = favouritesCount > 4 ? 54 : 0
        statsSeparationConstraint.constant = favouritesCount > 4 ? 17 : 0
        viewsStatsWidthConstraint.constant = viewsCount > 4 ? 54 : 0

        updateStatsWithInfo(viewsCount, favouritesCount: favouritesCount)
    }

    func updateStatsWithInfo(viewsCount: Int, favouritesCount: Int) {
        favouriteStatsLabel.text = favouritesCount < 1000 ? String(favouritesCount) : "+999"
        viewsStatsLabel.text = viewsCount < 1000 ? String(viewsCount) : "+999"

        layoutSubviews()
    }
}
