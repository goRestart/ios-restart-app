//
//  OpenListingErrorViewController.swift
//  LetGo
//
//  Created by Dídac on 17/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class OpenListingErrorViewController: BaseViewController, OpenListingErrorViewModelDelegate {

    private static let iconWidth: CGFloat = 164
    private static let iconHeight: CGFloat = 125
    private static let retryButtonWidth: CGFloat = 220
    private static let retryButtonHeight: CGFloat = 44
    private static let titleVerticalOffsetWithImage: CGFloat = 50
    private static let titleVerticalOffsetWithoutImage: CGFloat = -100

    private let closeButton: UIButton = UIButton()
    private let iconImageView: UIImageView = UIImageView()
    private let textLabel: UILabel = UILabel()
    private let retryButton: UIButton = UIButton()

    private var viewModel: OpenListingErrorViewModel


    // MARK: - Lifecycle

    init(viewModel: OpenListingErrorViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
        setupUI()
        setupLayout()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: private methods

    func setupUI() {
        view.backgroundColor = UIColor.white

        closeButton.setImage(UIImage(named: "ic_close_red"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)

        iconImageView.image = UIImage(named: "ic_item_unavailable")
        iconImageView.contentMode = .center

        textLabel.font = UIFont.systemBoldFont(size: 30)
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.blackText
        textLabel.text = LGLocalizedString.commonErrorLoadingListing
        textLabel.textAlignment = .center

        retryButton.frame = CGRect(x: 0, y: 0, width: 220, height: 44)
        retryButton.setStyle(.primary(fontSize: .medium))
        retryButton.setTitle(LGLocalizedString.commonErrorRetryButton, for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonPressed), for: .touchUpInside)
    }

    func setupLayout() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear

        containerView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubviews([iconImageView, textLabel, retryButton])
        view.addSubviews([closeButton, containerView])

        closeButton.layout().width(Metrics.closeButtonHeight).height(Metrics.closeButtonHeight)
        closeButton.layout(with: view).top(by: Metrics.bigMargin).left(by: Metrics.margin)

        containerView.layout(with: view).center()
            .trailingMargin(by: -Metrics.veryBigMargin, relatedBy: .lessThanOrEqual)
            .leadingMargin(by: Metrics.veryBigMargin, relatedBy: .greaterThanOrEqual)

        iconImageView.layout()
            .width(OpenListingErrorViewController.iconWidth)
            .height(OpenListingErrorViewController.iconHeight)
        iconImageView.layout(with: containerView).top().centerX()

        textLabel.layout(with: iconImageView).below(by: Metrics.veryBigMargin)
        textLabel.layout(with: containerView).centerX()
            .trailingMargin()
            .leadingMargin()

        retryButton.layout()
            .height(OpenListingErrorViewController.retryButtonHeight)
            .width(OpenListingErrorViewController.retryButtonWidth)
        retryButton.layout(with: textLabel).below(by: Metrics.veryBigMargin)
        retryButton.layout(with: containerView).bottom().centerX()
    }

    dynamic func closeButtonPressed() {
        viewModel.close(completion: nil)
    }

    dynamic func retryButtonPressed() {
        viewModel.retryButtonPressed()
    }

    func setupAccessibilityIds() {
        closeButton.accessibilityId = AccessibilityId.listingNotAvailableCloseButton
        iconImageView.accessibilityId = AccessibilityId.listingNotAvailableIcon
        textLabel.accessibilityId = AccessibilityId.listingNotAvailableTextLabel
        retryButton.accessibilityId = AccessibilityId.listingNotAvailableRetryButton
    }
}
