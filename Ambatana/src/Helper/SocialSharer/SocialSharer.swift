import LGComponents
import FBSDKShareKit
import MessageUI


protocol SocialSharerDelegate: class {
    func shareStartedIn(_ shareType: ShareType)
    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState)
}


class SocialSharer: NSObject {
    weak var delegate: SocialSharerDelegate?
}


// MARK: - Public methods
// MARK: > Share

extension SocialSharer {
    func share(_ socialMessage: SocialMessage,
               shareType: ShareType,
               viewController: UIViewController,
               barButtonItem: UIBarButtonItem? = nil,
               image: UIImage? = nil) {
        guard SocialSharer.canShareIn(shareType) else {
            delegate?.shareStartedIn(shareType)
            delegate?.shareFinishedIn(shareType, withState: .failed)
            return
        }

        switch shareType {
        case .email:
            shareInEmail(socialMessage, viewController: viewController)
        case .facebook:
            shareInFacebook(socialMessage, viewController: viewController, image: image)
        case .fbMessenger:
            shareInFBMessenger(socialMessage, image: image)
        case .whatsapp:
            shareInWhatsapp(socialMessage, viewController: viewController)
        case .twitter:
            shareInTwitter(socialMessage, viewController: viewController)
        case .telegram:
            shareInTelegram(socialMessage)
        case .copyLink:
            shareInPasteboard(socialMessage)
        case .sms:
            shareInSMS(socialMessage, viewController: viewController, image: image, messageComposeDelegate: self)
        case let .native(restricted):
            shareInNative(socialMessage,
                          viewController: viewController,
                          restricted: restricted,
                          barButtonItem: barButtonItem,
                          image: image)
        }
    }
}


// MARK: > Share helpers

extension SocialSharer {
    static func canShareIn(_ shareType: ShareType) -> Bool {
        switch shareType {
        case .email:
            return MFMailComposeViewController.canSendMail()
        case .facebook, .twitter, .native, .copyLink:
            return true
        case .fbMessenger:
            guard let url = URL(string: "fb-messenger-api://") else { return false }
            let application = UIApplication.shared
            return application.canOpenURL(url)
        case .whatsapp:
            guard let url = URL(string: "whatsapp://") else { return false }
            let application = UIApplication.shared
            return application.canOpenURL(url)
        case .telegram:
            guard let url = URL(string: "tg://") else { return false }
            let application = UIApplication.shared
            return application.canOpenURL(url)
        case .sms:
            return MFMessageComposeViewController.canSendText()
        }
    }

    static func canShareInAny(_ shareTypes: [ShareType]) -> Bool {
        for shareType in shareTypes {
            if canShareIn(shareType) {
                return true
            }
        }
        return false
    }
}


// MARK: - FBSDKSharingDelegate

extension SocialSharer: FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        guard sharer != nil else { return }

        switch sharer.type {
        case .facebook:
            // Delay added to let FBSDKSharing UI finish before informing Social Sharer Delegate
            delay(0.2, completion: { [weak self] in
                self?.delegate?.shareFinishedIn(.facebook, withState: .completed)
            })
        case .fbMessenger:
            // Messenger always calls didCompleteWithResults, if it works,
            // will include the key "completionGesture" in the results dict
            if let results = results, let _ = results["completionGesture"] {
                delegate?.shareFinishedIn(.fbMessenger, withState: .completed)
            } else {
                delegate?.shareFinishedIn(.fbMessenger, withState: .cancelled)
            }
        case .unknown:
            break
        }
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        guard sharer != nil else { return }

        switch sharer.type {
        case .facebook:
            delegate?.shareFinishedIn(.facebook, withState: .failed)
        case .fbMessenger:
            delegate?.shareFinishedIn(.fbMessenger, withState: .failed)
        case .unknown:
            break
        }
    }

    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        guard sharer != nil else { return }

        switch sharer.type {
        case .facebook:
            delegate?.shareFinishedIn(.facebook, withState: .cancelled)
        case .fbMessenger:
            delegate?.shareFinishedIn(.fbMessenger, withState: .cancelled)
        case .unknown:
            break
        }
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension SocialSharer: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        let state: SocialShareState
        switch result {
        case .failed:
            state = .failed
        case .sent:
            state = .completed
        case .cancelled, .saved:
            state = .cancelled
        }

        controller.dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.shareFinishedIn(.email, withState: state)
        })
    }
}


// MARK: - MFMessageComposeViewControllerDelegate

extension SocialSharer: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        let state: SocialShareState
        switch result {
        case .failed:
            state = .failed
        case .sent:
            state = .completed
        case .cancelled:
            state = .cancelled
        }

        controller.dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.shareFinishedIn(.sms, withState: state)
        })
    }
}


// MARK: - Private methods
// MARK: > Share

fileprivate extension SocialSharer {
    func shareInEmail(_ socialMessage: SocialMessage, viewController: UIViewController) {
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        emailVC.setSubject(socialMessage.emailShareSubject)
        socialMessage.retrieveEmailShareBody { body in
            emailVC.setMessageBody(body, isHTML: socialMessage.emailShareIsHtml)
            viewController.present(emailVC, animated: true) { [weak self] in
                self?.delegate?.shareStartedIn(.email)
            }
        }
    }

    func shareInFacebook(_ socialMessage: SocialMessage, viewController: UIViewController, image: UIImage? = nil) {
        delegate?.shareStartedIn(.facebook)
        socialMessage.retrieveFBShareContent(image: image) { fbShareContent in
            let dialog = FBSDKShareDialog()
            dialog.fromViewController = viewController
            dialog.shareContent = fbShareContent
            dialog.delegate = self
            
            dialog.show()
        }
    }

    func shareInFBMessenger(_ socialMessage: SocialMessage, image: UIImage?) {
        delegate?.shareStartedIn(.fbMessenger)
        socialMessage.retrieveFBMessengerShareContent(image: image) { fbMessengerShareContent in
            FBSDKMessageDialog.show(with: fbMessengerShareContent, delegate: self)
        }
    }

    func shareInWhatsapp(_ socialMessage: SocialMessage, viewController: UIViewController) {
        socialMessage.retrieveWhatsappShareText() { [weak self] shareText in
            self?.shareInURL(.whatsapp, image: nil, text: shareText, urlScheme: SharedConstants.whatsAppShareURL)
        }
    }

    func shareInTwitter(_ socialMessage: SocialMessage, viewController: UIViewController) {
        socialMessage.retrieveTwitterShareText { [weak self] shareText in
            self?.shareInURL(.twitter, image: nil, text: shareText, urlScheme: SharedConstants.twitterShareURL)
        }
    }

    func shareInTelegram(_ socialMessage: SocialMessage) {
        socialMessage.retrieveTelegramShareText { [weak self] shareText in
            self?.shareInURL(.telegram, image: nil, text: shareText, urlScheme: SharedConstants.telegramShareURL)
        }
    }

    func shareInPasteboard(_ socialMessage: SocialMessage) {
        delegate?.shareStartedIn(.copyLink)
        socialMessage.retrieveCopyLinkText { [weak self] text in
            UIPasteboard.general.string = text
            self?.delegate?.shareFinishedIn(.copyLink, withState: .completed)
        }
    }

    func shareInSMS(_ socialMessage: SocialMessage,
                    viewController: UIViewController,
                    image: UIImage?,
                    messageComposeDelegate: MFMessageComposeViewControllerDelegate) {
        let messageVC = MFMessageComposeViewController()
        socialMessage.retrieveSMSShareText { smsShareText in
            messageVC.body = smsShareText
            messageVC.recipients = []
            messageVC.messageComposeDelegate = messageComposeDelegate
            if let image = image, let data = UIImagePNGRepresentation(image) {
                messageVC.addAttachmentData(data, typeIdentifier: "public.data", filename: "image.png")
            }
            viewController.present(messageVC, animated: false) { [weak self] in
                self?.delegate?.shareStartedIn(.sms)
            }
        }
    }

    func shareInNative(_ socialMessage: SocialMessage,
                       viewController: UIViewController,
                       restricted: Bool,
                       barButtonItem: UIBarButtonItem? = nil,
                       image: UIImage? = nil) {
        socialMessage.retrieveNativeShareItems(image: image) { activityItems in
            let shareVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            
            if restricted {
                var excludedActivities: [UIActivityType] = []
                excludedActivities.append(.print)
                excludedActivities.append(.copyToPasteboard)
                excludedActivities.append(.assignToContact)
                excludedActivities.append(.saveToCameraRoll)
                excludedActivities.append(.addToReadingList)
                shareVC.excludedActivityTypes = excludedActivities
            }

            if shareVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                if let item = barButtonItem {
                    let presentationController = shareVC.popoverPresentationController
                    presentationController?.barButtonItem = item
                } else {
                    // fallback case if someone forgets to add a bar button item
                    shareVC.popoverPresentationController?.sourceView = viewController.view
                }
            }
            
            if shareVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)),
                let item = barButtonItem,
                let presentationController = shareVC.popoverPresentationController {
                presentationController.barButtonItem = item
            }
            
            shareVC.completionWithItemsHandler = { [weak self] (activity, success, items, error) in
                guard let strongSelf = self else { return }
                let shareType: ShareType
                if let activity = activity {
                    switch activity {
                    case UIActivityType.postToFacebook:
                        shareType = .facebook
                    case UIActivityType.postToTwitter:
                        shareType = .twitter
                    case UIActivityType.mail:
                        shareType = .email
                    case UIActivityType.copyToPasteboard:
                        shareType = .copyLink
                    default:
                        if let _ = activity.rawValue.range(of: "whatsapp") {
                            shareType = .whatsapp
                        } else {
                            shareType = .native(restricted: restricted)
                        }
                    }
                } else {
                    shareType = .native(restricted: restricted)
                }
                
                // Comment left here as a clue to manage future activities
                /*   SAMPLES OF SHARING RESULTS VIA ACTIVITY VC
                 
                 println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
                 
                 Activity: com.apple.UIKit.activity.PostToFacebook Success: true Items: nil Error: nil
                 Activity: net.whatsapp.WhatsApp.ShareExtension Success: true Items: nil Error: nil
                 Activity: com.apple.UIKit.activity.Mail Success: true Items: nil Error: nil
                 Activity: com.apple.UIKit.activity.PostToTwitter Success: true Items: nil Error: nil
                 */
                let state: SocialShareState
                if success {
                    state = .completed
                } else if let _  = error {
                    state = .failed
                } else {
                    state = .cancelled
                }
                strongSelf.delegate?.shareFinishedIn(shareType, withState: state)
            }
            viewController.present(shareVC, animated: true) { [weak self] in
                self?.delegate?.shareStartedIn(.native(restricted: restricted))
            }
        }
    }

    func shareInURL(_ shareType: ShareType, image: UIImage?, text: String, urlScheme: String) {
        delegate?.shareStartedIn(shareType)

        guard let url = SocialSharer.generateMessageShareURL(text, withUrlScheme: urlScheme) else {
            delegate?.shareFinishedIn(shareType, withState: .failed)
            return
        }

        if UIApplication.shared.openURL(url) {
            delegate?.shareFinishedIn(shareType, withState: .completed)
        } else {
            delegate?.shareFinishedIn(shareType, withState: .failed)
        }
    }
}


// MARK: > Helpers

fileprivate extension SocialSharer {
    static func generateMessageShareURL(_ socialMessageText: String, withUrlScheme scheme: String) -> URL? {
        let queryCharSet = NSMutableCharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]")
        queryCharSet.invert()
        queryCharSet.formIntersection(with: CharacterSet.urlQueryAllowed)
        guard let urlEncodedShareText = socialMessageText
            .addingPercentEncoding(withAllowedCharacters: queryCharSet as CharacterSet) else { return nil }
        return URL(string: String(format: scheme, urlEncodedShareText))
    }
}
