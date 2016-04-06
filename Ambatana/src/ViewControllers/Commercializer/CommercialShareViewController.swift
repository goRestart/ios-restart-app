//
//  CommercialShareViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 06/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class CommercialShareViewController: BaseViewController {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!

    weak var shareDelegate: SocialShareViewDelegate? {
        didSet {
            guard let socialShareView = socialShareView else { return }
            socialShareView.delegate = shareDelegate
        }
    }

    var socialMessage: SocialMessage? {
        didSet {
            guard let socialShareView = socialShareView else { return }
            socialShareView.socialMessage = socialMessage
        }
    }

    init() {
        super.init(viewModel: nil, nibName: "CommercialShareViewController")
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


    // MARK: - Actions

    @IBAction func backgroundButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        socialShareView.socialMessage = socialMessage
        socialShareView.delegate = shareDelegate
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialShareViewController: SocialShareViewDelegate {
    func shareInEmail(){
        shareDelegate?.shareInEmail()
    }

    func shareInFacebook() {
        shareDelegate?.shareInFacebook()
    }

    func shareInFacebookFinished(state: SocialShareState) {
        switch state {
        case .Completed, .Cancelled:
            shareDelegate?.shareInFacebookFinished(state)
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }

    func shareInFBMessenger() {
        shareDelegate?.shareInFBMessenger()
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        switch state {
        case .Completed, .Cancelled:
            shareDelegate?.shareInFBMessengerFinished(state)
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }

    func shareInWhatsApp() {
        shareDelegate?.shareInWhatsApp()
    }

    func shareInTwitter() {
        shareDelegate?.shareInTwitter()
    }

    func shareInTwitterFinished(state: SocialShareState) {
        switch state {
        case .Completed, .Cancelled:
            shareDelegate?.shareInTwitterFinished(state)
        case .Failed:
            break
        }
    }

    func shareInTelegram() {
        shareDelegate?.shareInTelegram()
    }

    func viewController() -> UIViewController? {
        return self
    }
}
