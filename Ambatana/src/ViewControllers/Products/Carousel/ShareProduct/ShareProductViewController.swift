//
//  ShareProductViewController.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ShareProductViewController: BaseViewController {

    private static let shareButtonWidth: CGFloat = 60
    private static let gradientSize: CGFloat = 30

    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var shareButtonsContainer: UIView!
    @IBOutlet weak var shareButtonsContainerWidth: NSLayoutConstraint!
    @IBOutlet var socialShareView: SocialShareView!

    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var linkButtonContainer: UIView!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var copyLabel: UILabel!

    @IBOutlet weak var copyButton: UIButton!

    @IBOutlet weak var gradientView: UIView!
    private var shadowLayer: CAGradientLayer?

    private var viewModel: ShareProductViewModel


    // MARK: - Lifecycle

    init(viewModel: ShareProductViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ShareProductViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


    // MARK: - Public Methods

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func copyButtonPressed(_ sender: AnyObject) {
        viewModel.copyLink()
    }


    // MARK: - Private Methods

    private func setupUI() {

        view.layoutIfNeeded()
        
        shareButtonsContainerWidth.constant = CGFloat(viewModel.shareTypes.count)*ShareProductViewController.shareButtonWidth
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        orLabel.text = LGLocalizedString.commonOr
        copyLabel.text = LGLocalizedString.commonCopy
        linkLabel.text = viewModel.link
        linkButtonContainer.layer.cornerRadius = LGUIKitConstants.textfieldCornerRadius

        setupShareView()
        setupGradientView()
    }

    private func setupShareView() {
        socialShareView.socialMessage = viewModel.socialMessage
        socialShareView.setupWithShareTypes(viewModel.shareTypes, useBigButtons: true)
        socialShareView.socialSharer = viewModel.socialSharer
        socialShareView.delegate = self
        socialShareView.buttonsSide = ShareProductViewController.shareButtonWidth
        socialShareView.style = .line
    }

    private func setupGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        let gradientFinishSpot = NSNumber(value: Float(ShareProductViewController.gradientSize/gradientView.frame.width))
        shadowLayer = CAGradientLayer.gradientWithColor(UIColor.listBackgroundColor, alphas:[0, 1], locations: [0, gradientFinishSpot])
        if let shadowLayer = shadowLayer {
            // make it horitzontal
            shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
            shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)

            shadowLayer.frame = gradientView.bounds
            gradientView.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}


extension ShareProductViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}


extension ShareProductViewController: ShareProductViewModelDelegate {
    func vmViewControllerToShare() -> UIViewController {
        return self
    }
    
    func viewControllerShouldClose() {
        dismiss(animated: true, completion: nil)
    }
}

extension ShareProductViewController {
    func setAccessibilityIds() {
        view.accessibilityId = AccessibilityId.productCarouselFullscreenShareView
        closeButton.accessibilityId = AccessibilityId.productCarouselFullscreenShareCloseButton
        copyButton.accessibilityId = AccessibilityId.productCarouselFullscreenShareCopyLinkButton
    }
}
