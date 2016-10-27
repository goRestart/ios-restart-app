//
//  ShareProductViewController.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ShareProductViewController: BaseViewController {

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
    var shadowLayer: CALayer?

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
    }

    @IBAction func copyButtonPressed(sender: AnyObject) {
    }


    // MARK: - Private Methods

    private func setupUI() {

        titleLabel.text = ""
        subtitleLabel.text = ""
        orLabel.text = "_ OR"

        copyLabel.text = "_Copy"

        setupShareView()
        setupGradientView()
    }

    private func setupShareView() {
        socialShareView.setupWithShareTypes(viewModel.shareTypes)
        socialShareView.socialMessage = viewModel.socialMessage
        socialShareView.delegate = self
        socialShareView.buttonsSide = 60
        socialShareView.style = .Line
    }

    private func setupGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        shadowLayer = CAGradientLayer.gradientWithColor(UIColor.grayLighter, alphas:[0, 1], locations: [0, 1])
        if let shadowLayer = shadowLayer {
            shadowLayer.frame = gradientView.bounds
            gradientView.layer.insertSublayer(shadowLayer, atIndex: 0)
        }
    }
}


extension ShareProductViewController: ShareProductViewModelDelegate {

}


extension ShareProductViewController: SocialShareViewDelegate {
    func shareInEmail() {}

    func shareInEmailFinished(state: SocialShareState) {}

    func shareInFacebook() {}

    func shareInFacebookFinished(state: SocialShareState) {}

    func shareInFBMessenger() {}

    func shareInFBMessengerFinished(state: SocialShareState) {}

    func shareInWhatsApp() {}

    func shareInTwitter() {}

    func shareInTwitterFinished(state: SocialShareState) {}

    func shareInTelegram() {}

    func shareInSMS() {}

    func shareInSMSFinished(state: SocialShareState) {}

    func shareInCopyLink() {}

    func viewController() -> UIViewController?  {
        return self
    }

    func openNativeShare() {
        presentNativeShare(socialMessage: viewModel.socialMessage, delegate: self)
    }
}

extension ShareProductViewController: NativeShareDelegate {

    var nativeShareSuccessMessage: String? { return LGLocalizedString.productShareGenericOk }
    var nativeShareErrorMessage: String? { return LGLocalizedString.productShareGenericError }

    func nativeShareInFacebook() {}

    func nativeShareInTwitter() {}

    func nativeShareInEmail() {}

    func nativeShareInWhatsApp() {}
}
