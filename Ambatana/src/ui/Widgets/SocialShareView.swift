//
//  SocialShareView.swift
//  LetGo
//
//  Created by Eli Kohen on 15/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MessageUI

enum SocialShareState {
    case Completed
    case Cancelled
    case Failed
}

protocol SocialShareViewDelegate: class {
    func shareInEmail()
    func shareInFacebook()
    func shareInFacebookFinished(state: SocialShareState)
    func shareInFBMessenger()
    func shareInFBMessengerFinished(state: SocialShareState)
    func shareInWhatsApp()
    func viewController() -> UIViewController?
}

@IBDesignable
public class SocialShareView: UIView {

    // Our custom view from the XIB file
    var view: UIView!

    @IBOutlet weak var fbMessengerButton: UIButton!
    @IBOutlet weak var fbMessengerWidth: NSLayoutConstraint!

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var facebookWidth: NSLayoutConstraint!

    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailWidth: NSLayoutConstraint!

    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var whatsappWidth: NSLayoutConstraint!

    weak var delegate: SocialShareViewDelegate?
    var socialMessage: SocialMessage? {
        didSet {
            checkAllowedButtons()
        }
    }

    private static let buttonsWidth: CGFloat = 56


    // MARK: - View Lifecycle

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        xibSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        xibSetup()
    }


    // MARK: - IBActions

    @IBAction func onShareFbMessenger(sender: AnyObject) {
        guard let socialMessage = socialMessage else { return }

        delegate?.shareInFBMessenger()
        FBSDKMessageDialog.showWithContent(socialMessage.fbShareContent, delegate: self)
    }

    @IBAction func onShareFacebook(sender: AnyObject) {
        guard let socialMessage = socialMessage else { return }
        guard let viewController = delegate?.viewController() else { return }

        delegate?.shareInFacebook()
        FBSDKShareDialog.showFromViewController(viewController, withContent: socialMessage.fbShareContent,
            delegate: self)
    }

    @IBAction func onShareEmail(sender: AnyObject) {
        guard let viewController = delegate?.viewController() else { return }
        guard let socialMessage = socialMessage else { return }

        let isEmailAccountConfigured = MFMailComposeViewController.canSendMail()
        if isEmailAccountConfigured {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setSubject(socialMessage.title)
            vc.setMessageBody(socialMessage.emailShareText, isHTML: false)
            viewController.presentViewController(vc, animated: true, completion: nil)
            delegate?.shareInEmail()
        }
        else {
            viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareEmailError)
        }
    }

    @IBAction func onShareWhatsapp(sender: AnyObject) {
        guard let url = generateWhatsappURL() else { return }

        delegate?.shareInWhatsApp()

        if !UIApplication.sharedApplication().openURL(url) {
            delegate?.viewController()?.showAutoFadingOutMessageAlert(LGLocalizedString.productShareWhatsappError)
        }
    }


    // MARK: - Private methods

    private func xibSetup() {

        if view != nil {
            //Alrady initialized
            return
        }

        backgroundColor = UIColor.clearColor()
        view = loadViewFromNib()

        // Adding custom subview on top of our view
        addSubview(view)
        let xConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        addConstraints([xConstraint, yConstraint])

        checkAllowedButtons()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: SocialShareView.self)
        return bundle.loadNibNamed("SocialShareView", owner: self, options: nil).first as! UIView
    }

    private func checkAllowedButtons() {
        fbMessengerWidth.constant = canShareInFBMessenger() ? SocialShareView.buttonsWidth : 0
        whatsappWidth.constant = canShareInWhatsapp() ? SocialShareView.buttonsWidth : 0
    }

    func generateWhatsappURL() -> NSURL? {
        guard let socialMessage = socialMessage else { return nil }

        let queryCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        guard let urlEncodedShareText = socialMessage.shareText
            .stringByAddingPercentEncodingWithAllowedCharacters(queryCharSet) else { return nil }
        return NSURL(string: String(format: Constants.whatsAppShareURL, arguments: [urlEncodedShareText]))
    }

    private func canShareInWhatsapp() -> Bool {
        guard let url = generateWhatsappURL() else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }

    private func canShareInFBMessenger() -> Bool {
        guard let url = NSURL(string: "fb-messenger-api://") else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }
}


// MARK: - FBSDKSharingDelegate

extension SocialShareView: FBSDKSharingDelegate {

    public func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {

        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFacebookFinished(.Completed)
        case .FBMessenger:
            // Messenger always calls didCompleteWithResults, if it works,
            // will include the key "completionGesture" in the results dict
            if let _ = results["completionGesture"] {
                delegate?.shareInFBMessengerFinished(.Completed)
            }
            else {
                delegate?.shareInFBMessengerFinished(.Cancelled)
            }
        case .Unknown:
            break
        }
    }

    public func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFBMessengerFinished(.Failed)
        case .FBMessenger:
            delegate?.shareInFBMessengerFinished(.Failed)
        case .Unknown:
            break
        }
    }

    public func sharerDidCancel(sharer: FBSDKSharing!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFBMessengerFinished(.Cancelled)
        case .FBMessenger:
            delegate?.shareInFBMessengerFinished(.Cancelled)
        case .Unknown:
            break
        }
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension SocialShareView: MFMailComposeViewControllerDelegate {
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult
        result: MFMailComposeResult, error: NSError?) {
            var message: String? = nil
            if result.rawValue == MFMailComposeResultFailed.rawValue {
                // we just give feedback if something nasty happened.
                message = LGLocalizedString.productShareEmailError
            }

            controller.dismissViewControllerAnimated(true, completion: { [weak self] in
                guard let message = message else { return }
                self?.delegate?.viewController()?.showAutoFadingOutMessageAlert(message)
            })
    }
}

