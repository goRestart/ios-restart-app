//
//  FeaturedInfoViewController.swift
//  LetGo
//
//  Created by Dídac on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class FeaturedInfoViewController: BaseViewController {

    private static let tipsIconHeight: CGFloat = 75

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

    private var viewModel: FeaturedInfoViewModel

    // MARK: - Lifecycle

    init(viewModel: FeaturedInfoViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        modalPresentationStyle = .overCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    // MARK: UI

    func setupUI() {
        view.backgroundColor = UIColor.white
        closeButton.setImage(UIImage(named: "ic_close_red"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)

        titleIcon.image = UIImage(named: "ic_lightning")
        titleIcon.contentMode = .scaleAspectFit
        titleLabel.text = viewModel.titleText
        titleLabel.font = UIFont.systemSemiBoldFont(size: 17)
        titleLabel.textColor = UIColor.blackText

        sellFasterIcon.image = UIImage(named: "ic_sell_faster")
        sellFasterIcon.contentMode = .center
        sellFasterLabel.text = viewModel.sellFasterText
        sellFasterLabel.font = UIFont.systemBoldFont(size: 27)
        sellFasterLabel.textColor = UIColor.blackText
        sellFasterLabel.numberOfLines = 0

        increaseVisibilityIcon.image = UIImage(named: "ic_visibility")
        increaseVisibilityIcon.contentMode = .center
        increaseVisibilityLabel.text = viewModel.increaseVisibilityText
        increaseVisibilityLabel.font = UIFont.systemBoldFont(size: 27)
        increaseVisibilityLabel.textColor = UIColor.blackText
        increaseVisibilityLabel.numberOfLines = 0

        moreBuyersIcon.image = UIImage(named: "ic_interested_buyers")
        moreBuyersIcon.contentMode = .center
        moreBuyersLabel.text = viewModel.moreBuyersText
        moreBuyersLabel.font = UIFont.systemBoldFont(size: 27)
        moreBuyersLabel.textColor = UIColor.blackText
        moreBuyersLabel.numberOfLines = 0
    }

    func setupConstraints() {

        let baseViews: [UIView] = [closeButton, titleContainer, tipsContainer]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: baseViews)
        view.addSubviews(baseViews)

        view.addSubview(closeButton)

        closeButton.layout().width(Metrics.closeButtonWidth).height(Metrics.closeButtonHeight)
        closeButton.layout(with: view).top(by: Metrics.margin).left()

        // title
        titleContainer.layout(with: view).centerX().top(by: Metrics.veryBigMargin)
        titleContainer.layout(with: closeButton).left(to: .right, by: Metrics.bigMargin, relatedBy: .greaterThanOrEqual)

        let titleViews: [UIView] = [titleIcon, titleLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: titleViews)
        titleContainer.addSubviews(titleViews)

        titleIcon.layout().width(Metrics.bigMargin)
        titleIcon.layout(with: titleContainer).left().top().bottom().centerY()

        titleIcon.layout(with: titleLabel).right(to: .left, by: -Metrics.shortMargin)
        titleLabel.layout(with: titleContainer).right().top().bottom().centerY()

        // tips
        tipsContainer.layout(with: view).center().fillHorizontal(by: Metrics.veryBigMargin)
        tipsContainer.layout(with: titleContainer).top(to: .bottom, by: Metrics.bigMargin, relatedBy: .greaterThanOrEqual)

        let tipsViews: [UIView] = [sellFasterContainer, increaseVisibilityContainer, moreBuyersContainer]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: tipsViews)
        tipsContainer.addSubviews(tipsViews)

        sellFasterContainer.layout(with: tipsContainer).top().fillHorizontal()
        increaseVisibilityContainer.layout(with: tipsContainer).fillHorizontal()
        increaseVisibilityContainer.layout(with: sellFasterContainer).top(to: .bottom)
        increaseVisibilityContainer.layout(with: moreBuyersContainer).bottom(to: .top)
        moreBuyersContainer.layout(with: tipsContainer).bottom().fillHorizontal()

        let iconHeight = FeaturedInfoViewController.tipsIconHeight

        // sell faster tip
        let sellFasterViews: [UIView] = [sellFasterIcon, sellFasterLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: sellFasterViews)
        sellFasterContainer.addSubviews(sellFasterViews)

        sellFasterIcon.layout().width(iconHeight).height(iconHeight)
        sellFasterIcon.layout(with: sellFasterContainer)
            .left()
            .top(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin, relatedBy: .greaterThanOrEqual)
            .centerY()

        sellFasterIcon.layout(with: sellFasterLabel).right(to: .left, by: -Metrics.veryBigMargin)
        sellFasterLabel.layout(with: sellFasterContainer).right().top().bottom().centerY()

        // increase visibility tip
        let increaseVisibilityViews: [UIView] = [increaseVisibilityIcon, increaseVisibilityLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: increaseVisibilityViews)
        increaseVisibilityContainer.addSubviews(increaseVisibilityViews)

        increaseVisibilityIcon.layout().width(iconHeight).height(iconHeight)
        increaseVisibilityIcon.layout(with: increaseVisibilityContainer)
            .left()
            .top(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin, relatedBy: .greaterThanOrEqual)
            .centerY()

        increaseVisibilityIcon.layout(with: increaseVisibilityLabel).right(to: .left, by: -Metrics.veryBigMargin)
        increaseVisibilityLabel.layout(with: increaseVisibilityContainer).right().top().bottom().centerY()

        // more buyers tip
        let moreBuyersViews: [UIView] = [moreBuyersIcon, moreBuyersLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: moreBuyersViews)
        moreBuyersContainer.addSubviews(moreBuyersViews)

        moreBuyersIcon.layout().width(iconHeight).height(iconHeight)
        moreBuyersIcon.layout(with: moreBuyersContainer)
            .left()
            .top(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin, relatedBy: .greaterThanOrEqual)
            .centerY()

        moreBuyersIcon.layout(with: moreBuyersLabel).right(to: .left, by: -Metrics.veryBigMargin)
        moreBuyersLabel.layout(with: moreBuyersContainer).right().top().bottom().centerY()
    }

    func setAccessibilityIds() {
        closeButton.accessibilityId = .featuredInfoCloseButton
    }

    // MARK: Actions

    dynamic func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
}
