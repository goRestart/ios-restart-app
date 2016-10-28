//
//  ShareProductViewController.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ShareProductViewController: BaseViewController {

    static let shareButtonWidth = 60
    static let gradientSize = 30

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var shareButtonsContainer: UIView!
    @IBOutlet weak var shareButtonsContainerWidth: NSLayoutConstraint!
    @IBOutlet var socialShareView: SocialShareView!

    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var linkButtonContainer: UIView!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var copyLabel: UILabel!

    @IBOutlet weak var gradientView: UIView!
    var shadowLayer: CAGradientLayer?

    var viewModel: ShareProductViewModel


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

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func copyButtonPressed(sender: AnyObject) {
        guard let socialMessage = viewModel.socialMessage else { return }
        SocialHelper.shareOnCopyLink(socialMessage, viewController: self)
    }


    // MARK: - Private Methods

    private func setupUI() {
        view.layoutIfNeeded()
        // TODO: uncomment localized vars when validated
        titleLabel.text = "_SHARING IS WINNING!" //LGLocalizedString.productShareFullscreenTitle
        subtitleLabel.text = "_Did you know that those who share their products are 100% more likely to be awesome?" //LGLocalizedString.productShareFullscreenSubtitle
        orLabel.text = "_OR" //LGLocalizedString.commonOr
        copyLabel.text = "_Copy" //LGLocalizedString.commonCopy
        linkLabel.text = viewModel.link
        linkButtonContainer.layer.cornerRadius = LGUIKitConstants.textfieldCornerRadius
        setupShareView()
        setupGradientView()

        shareButtonsContainerWidth.constant = CGFloat(viewModel.shareTypes.count*ShareProductViewController.shareButtonWidth)
    }

    private func setupShareView() {
        socialShareView.setupWithShareTypes(viewModel.shareTypes)
        socialShareView.socialMessage = viewModel.socialMessage
        socialShareView.delegate = viewModel.shareDelegate
        socialShareView.buttonsSide = 60
        socialShareView.style = .Line
    }

    private func setupGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        let gradientFinishSpot = CGFloat(ShareProductViewController.gradientSize)/gradientView.frame.width
        shadowLayer = CAGradientLayer.gradientWithColor(UIColor.listBackgroundColor, alphas:[0, 1], locations: [0, gradientFinishSpot])
        if let shadowLayer = shadowLayer {
            // make it horitzontal
            shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
            shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)

            shadowLayer.frame = gradientView.bounds
            gradientView.layer.insertSublayer(shadowLayer, atIndex: 0)
        }
    }
}


extension ShareProductViewController: ShareProductViewModelDelegate {

}


//extension ShareProductViewController: SocialShareViewDelegate {
//    func shareInEmail() {}
//
//    func shareInEmailFinished(state: SocialShareState) {}
//
//    func shareInFacebook() {}
//
//    func shareInFacebookFinished(state: SocialShareState) {}
//
//    func shareInFBMessenger() {}
//
//    func shareInFBMessengerFinished(state: SocialShareState) {}
//
//    func shareInWhatsApp() {}
//
//    func shareInTwitter() {}
//
//    func shareInTwitterFinished(state: SocialShareState) {}
//
//    func shareInTelegram() {}
//
//    func shareInSMS() {}
//
//    func shareInSMSFinished(state: SocialShareState) {}
//
//    func shareInCopyLink() {}
//
//    func viewController() -> UIViewController?  {
//        return self
//    }
//
//    func openNativeShare() {
//        presentNativeShare(socialMessage: viewModel.socialMessage, delegate: self)
//    }
//}

//extension ShareProductViewController: NativeShareDelegate {
//
//    var nativeShareSuccessMessage: String? { return LGLocalizedString.productShareGenericOk }
//    var nativeShareErrorMessage: String? { return LGLocalizedString.productShareGenericError }
//
//    func nativeShareInFacebook() {}
//
//    func nativeShareInTwitter() {}
//
//    func nativeShareInEmail() {}
//
//    func nativeShareInWhatsApp() {}
//}
