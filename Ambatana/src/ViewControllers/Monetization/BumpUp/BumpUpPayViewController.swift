//
//  BumpUpPayViewController.swift
//  LetGo
//
//  Created by Dídac on 19/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class BumpUpPayViewController: BaseViewController {

    private static let titleVerticalOffsetWithImage: CGFloat = 100
    private static let titleVerticalOffsetWithoutImage: CGFloat = -100

    @IBOutlet weak var closeButtonSafeAreaTopAlignment: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var featuredBackgroundImageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var cellBottomContainer: UIView!
    @IBOutlet weak var bumpUpButton: UIButton!

    private var shadowLayer: CALayer?

    private var viewModel: BumpUpPayViewModel

    // MARK: - Lifecycle

    init(viewModel: BumpUpPayViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "BumpUpPayViewController")
        modalPresentationStyle = .overCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccessibilityIds()

        if !isSafeAreaAvailable {
            closeButtonSafeAreaTopAlignment.constant = Metrics.veryBigMargin
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        infoContainer.cornerRadius = LGUIKitConstants.bigCornerRadius
        imageContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }

    // MARK: - Private methods

    func setupUI() {

        viewTitleLabel.text = LGLocalizedString.bumpUpBannerPayTextImprovement
        infoContainer.layer.masksToBounds = false
        infoContainer.applyShadow(withOpacity: 0.05, radius: 5)

        imageContainer.clipsToBounds = true
        imageContainer.layer.masksToBounds = false
        imageContainer.applyShadow(withOpacity: 0.25, radius: 5)

        if let imageUrl = viewModel.listing.images.first?.fileURL {
            listingImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
                [weak self] (result, url) -> Void in
                if let _ = result.value {
                    self?.imageContainer.isHidden = false
                } else {
                    self?.imageContainer.isHidden = true
                }
            })
        } else {
            imageContainer.isHidden = true
        }

        listingImageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        cellBottomContainer.clipsToBounds = true
        cellBottomContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        titleLabel.text = LGLocalizedString.bumpUpViewPayTitle
        subtitleLabel.text = LGLocalizedString.bumpUpViewPaySubtitle

        bumpUpButton.setStyle(.primary(fontSize: .big))
        bumpUpButton.setTitle(LGLocalizedString.bumpUpViewPayButtonTitle(viewModel.price), for: .normal)
        bumpUpButton.titleLabel?.numberOfLines = 2
        bumpUpButton.titleLabel?.adjustsFontSizeToFitWidth = true
        bumpUpButton.titleLabel?.minimumScaleFactor = 0.8

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    @objc private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func bumpUpButtonPressed(_ sender: AnyObject) {
        viewModel.bumpUpPressed()
    }

    private func setAccessibilityIds() {
        closeButton.set(accessibilityId: .paymentBumpUpCloseButton)
        listingImageView.set(accessibilityId: .paymentBumpUpImage)
        titleLabel.set(accessibilityId: .paymentBumpUpTitleLabel)
        subtitleLabel.set(accessibilityId: .paymentBumpUpSubtitleLabel)
        bumpUpButton.set(accessibilityId: .paymentBumpUpButton)
    }
}
