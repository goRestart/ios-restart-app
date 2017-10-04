//
//  OldBumpUpPayViewController.swift
//  LetGo
//
//  Created by Dídac on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class OldBumpUpPayViewController: BaseViewController {

    private static let titleVerticalOffsetWithImage: CGFloat = 100
    private static let titleVerticalOffsetWithoutImage: CGFloat = -100

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var featuredLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bumpUpButton: UIButton!

    @IBOutlet weak var  titleVerticalCenterConstraint: NSLayoutConstraint!

    private var viewModel: BumpUpPayViewModel

    // MARK: - Lifecycle

    init(viewModel: BumpUpPayViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "OldBumpUpPayViewController")
        self.viewModel.delegate = self
        modalPresentationStyle = .overCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccessibilityIds()
    }

    // MARK: - Private methods

    func setupUI() {

        if let imageUrl = viewModel.listing.images.first?.fileURL {
            listingImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
                [weak self] (result, url) -> Void in
                if let _ = result.value {
                    self?.titleVerticalCenterConstraint.constant = OldBumpUpPayViewController.titleVerticalOffsetWithImage
                    self?.imageContainer.isHidden = false
                } else {
                    self?.titleVerticalCenterConstraint.constant = OldBumpUpPayViewController.titleVerticalOffsetWithoutImage
                    self?.imageContainer.isHidden = true
                }
            })
        } else {
            titleVerticalCenterConstraint.constant = OldBumpUpPayViewController.titleVerticalOffsetWithoutImage
            imageContainer.isHidden = true
        }

        listingImageView.layer.cornerRadius = LGUIKitConstants.listingCellCornerRadius
        titleLabel.text = LGLocalizedString.bumpUpViewPayTitle
        subtitleLabel.text = LGLocalizedString.bumpUpViewPaySubtitle

        let rotation = CGFloat(Double.pi/4)
        featuredLabel.transform = CGAffineTransform(rotationAngle: rotation)
        featuredLabel.text = LGLocalizedString.bumpUpProductCellFeaturedStripe
        bumpUpButton.setStyle(.primary(fontSize: .medium))
        bumpUpButton.setTitle(LGLocalizedString.bumpUpViewPayButtonTitle(viewModel.price), for: .normal)


        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func bumpUpButtonPressed(_ sender: AnyObject) {
        viewModel.bumpUpPressed()
    }

    private func setAccessibilityIds() {
        closeButton.accessibilityId = .paymentBumpUpCloseButton
        listingImageView.accessibilityId = .paymentBumpUpImage
        titleLabel.accessibilityId = .paymentBumpUpTitleLabel
        subtitleLabel.accessibilityId = .paymentBumpUpSubtitleLabel
        bumpUpButton.accessibilityId = .paymentBumpUpButton
    }
}


// MARK: - BumpUpPayViewModelDelegate

extension OldBumpUpPayViewController: BumpUpPayViewModelDelegate {}
