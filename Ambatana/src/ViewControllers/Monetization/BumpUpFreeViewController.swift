//
//  BumpUpFreeViewController.swift
//  LetGo
//
//  Created by Dídac on 15/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class BumpUpFreeViewController: BaseViewController {

    private static let shareButtonWidth: CGFloat = 60
    private static let titleVerticalOffsetWithImage: CGFloat = 50
    private static let titleVerticalOffsetWithoutImage: CGFloat = -100

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var shareButtonsContainer: UIView!
    @IBOutlet weak var socialShareView: SocialShareView!

    @IBOutlet weak var  titleVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var  shareButtonsContainerWidth: NSLayoutConstraint!

    private var viewModel: ShareProductViewModel

    
    // MARK: - Lifecycle

    init(viewModel: ShareProductViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "BumpUpFreeViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccessibilityIds()
    }

    // MARK: private methods

    func setupUI() {
        if let imageUrl = viewModel.product.images.first?.fileURL {
            productImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
                [weak self] (result, url) -> Void in
                if let _ = result.value {
                    self?.titleVerticalCenterConstraint.constant = BumpUpFreeViewController.titleVerticalOffsetWithImage
                    self?.imageContainer.hidden = false
                } else {
                    self?.titleVerticalCenterConstraint.constant = BumpUpFreeViewController.titleVerticalOffsetWithoutImage
                    self?.imageContainer.hidden = true
                }
            })
        } else {
            titleVerticalCenterConstraint.constant = BumpUpFreeViewController.titleVerticalOffsetWithoutImage
            imageContainer.hidden = true
        }

        productImageView.layer.cornerRadius = LGUIKitConstants.productCellCornerRadius
        shareButtonsContainerWidth.constant = CGFloat(viewModel.shareTypes.count)*BumpUpFreeViewController.shareButtonWidth
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle

        setupShareView()

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .Down
        view.addGestureRecognizer(swipeDownGesture)
    }

    private func setupShareView() {
        socialShareView.socialMessage = viewModel.socialMessage
        socialShareView.setupWithShareTypes(viewModel.shareTypes, useBigButtons: true)
        socialShareView.socialSharer = viewModel.socialSharer
        socialShareView.delegate = self
        socialShareView.buttonsSide = BumpUpFreeViewController.shareButtonWidth
        socialShareView.style = .Line
    }

    private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    private func setAccessibilityIds() {
        closeButton.accessibilityId = .FreeBumpUpCloseButton
        productImageView.accessibilityId = .FreeBumpUpImage
        titleLabel.accessibilityId = .FreeBumpUpTitleLabel
        subtitleLabel.accessibilityId = .FreeBumpUpSubtitleLabel
        socialShareView.accessibilityId = .FreeBumpUpSocialShareView
    }
}

extension BumpUpFreeViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}

extension BumpUpFreeViewController: ShareProductViewModelDelegate {
    func vmViewControllerToShare() -> UIViewController {
        return self
    }

    func viewControllerShouldClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
