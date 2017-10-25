//
//  FeaturedInfoView.swift
//  LetGo
//
//  Created by Dídac on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class FeaturedInfoView: UIView {

    private let closeButton: UIButton = UIButton()

    private let titleContainer: UIView = UIView()
    private let titleIcon: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()


    private let tipsContainer: UIView = UIView()

    private let sellFasterContainer: UIView = UIView()
    private let sellFasterIcon: UIImageView = UIImageView()
    private let sellFasterLabel: UILabel = UILabel()

    private let increaseVisibilityContainer: UIView = UIView()
    private let increaseVisibilityIcon: UIImageView = UIImageView()
    private let increaseVisibilityLabel: UILabel = UILabel()

    private let moreBuyersContainer: UIView = UIView()
    private let moreBuyersIcon: UIImageView = UIImageView()
    private let moreBuyersLabel: UILabel = UILabel()


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        setupConstraints()
    }


    // MARK: UI

    func setupUI() {
        titleIcon.image = UIImage(named: "ic_lightning")
        titleLabel.text = LGLocalizedString.featuredInfoViewTitle

        sellFasterIcon.image = UIImage(named: "ic_sell_faster")
        sellFasterLabel.text = LGLocalizedString.featuredInfoViewSellFaster

        increaseVisibilityIcon.image = UIImage(named: "ic_visibility")
        increaseVisibilityLabel.text = LGLocalizedString.featuredInfoViewIncreaseVisibility

        moreBuyersIcon.image = UIImage(named: "ic_interested_buyers")
        moreBuyersLabel.text = LGLocalizedString.featuredInfoViewMoreBuyers
    }

    func setupConstraints() {

    }

}
