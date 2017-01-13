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

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var featuredLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bumpUpButton: UIButton!
    @IBOutlet weak var bumpsLeftLabel: UILabel!

    @IBOutlet weak var  titleVerticalCenterConstraint: NSLayoutConstraint!

    private var viewModel: BumpUpPayViewModel

    // MARK: - Lifecycle

    init(viewModel: BumpUpPayViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "BumpUpPayViewController")
        self.viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
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

        if let imageUrl = viewModel.product.images.first?.fileURL {
            productImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
                [weak self] (result, url) -> Void in
                if let _ = result.value {
                    self?.titleVerticalCenterConstraint.constant = BumpUpPayViewController.titleVerticalOffsetWithImage
                    self?.imageContainer.hidden = false
                } else {
                    self?.titleVerticalCenterConstraint.constant = BumpUpPayViewController.titleVerticalOffsetWithoutImage
                    self?.imageContainer.hidden = true
                }
                })
        } else {
            titleVerticalCenterConstraint.constant = BumpUpPayViewController.titleVerticalOffsetWithoutImage
            imageContainer.hidden = true
        }

        productImageView.layer.cornerRadius = LGUIKitConstants.productCellCornerRadius
        titleLabel.text = LGLocalizedString.bumpUpViewPayTitle
        subtitleLabel.text = LGLocalizedString.bumpUpViewPaySubtitle

        let rotation = CGFloat(M_PI_4)
        featuredLabel.transform = CGAffineTransformMakeRotation(rotation)
        bumpUpButton.setStyle(.Primary(fontSize: .Medium))
        bumpUpButton.setTitle(LGLocalizedString.bumpUpViewPayButtonTitle(viewModel.price), forState: .Normal)

        bumpsLeftLabel.text = String(format: LGLocalizedString.bumpUpViewPayBumpsLeftText, Int(viewModel.bumpsLeft))

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .Down
        view.addGestureRecognizer(swipeDownGesture)
    }

    private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func bumpUpButtonPressed(sender: AnyObject) {
        viewModel.bumpUpPressed()
    }

    private func setAccessibilityIds() {
        closeButton.accessibilityId = .PaymentBumpUpCloseButton
        productImageView.accessibilityId = .PaymentBumpUpImage
        titleLabel.accessibilityId = .PaymentBumpUpTitleLabel
        subtitleLabel.accessibilityId = .PaymentBumpUpSubtitleLabel
        bumpUpButton.accessibilityId = .PaymentBumpUpButton
        bumpsLeftLabel.accessibilityId = .PaymentBumpUpBumpsLeftLabel
    }
}


// MARK: - BumpUpPayViewModelDelegate

extension BumpUpPayViewController: BumpUpPayViewModelDelegate {}
