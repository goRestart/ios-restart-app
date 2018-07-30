import Foundation
import LGComponents

protocol CustomLeanplumPresenter {
    func showLeanplumAlert(_ title: String?, text: String, image: String, action: UIAction)
    func showLPMessageAlert(_ message: LPMessage)
}

struct LPMessage {
    let type: LPMessageType
    let headline: String
    let subHeadline: String
    let image: UIImage
    let action: UIAction
}

enum LPMessageType: String {
    case centerPopup = "LETGO_CENTER_POPUP"
    case interstitial = "LETGO_INTERSTITIAL"
}

extension Leanplum {
    private enum Keys {
        enum InApp {
            static let customPopUp = "LETGO_POPUP" // until we figure out if we can delete this.
        }
        static let title = "Title"
        static let messageText = "MessageText"
        static let image = "Image"
        static let buttonText = "ButtonText"
        static let action = "Accept action"
    }
    
    static func customLeanplumAlert(_ presenter: CustomLeanplumPresenter) {
        
        let argumentTitle = LPActionArg(named: Keys.title, with: "")
        let argumentMessage = LPActionArg(named: Keys.messageText, with: "")
        let argumentImage = LPActionArg(named: Keys.image, withFile: nil)
        let argumentButton = LPActionArg(named: Keys.buttonText, with: "")
        let argumentAction = LPActionArg(named: Keys.action, withAction: nil)
        let arguments = [argumentTitle, argumentMessage,
                         argumentImage, argumentButton, argumentAction].compactMap { $0 }
        // ofKind: LeanplumActionKind | kLeanplumActionKindAction  need to be set as rawValue.

        Leanplum.defineAction(Keys.InApp.customPopUp,
                              of: LeanplumActionKind(rawValue: 0b11),
                              withArguments: arguments,
                              withOptions: [:],
                              withResponder:  { (context: LPActionContext?) -> Bool in

                                guard let context = context else { return false }
                                guard let message = context.stringNamed(Keys.messageText) else { return false }
                                guard let image = context.fileNamed(Keys.image) else { return false }
                                guard let buttonText = context.stringNamed(Keys.buttonText) else { return false }

                                let title = context.stringNamed(Keys.title)
                                let okAction = UIAction(interface: .styledText(buttonText, .standard),
                                                        action: { context.runTrackedActionNamed(Keys.action) },
                                                        accessibility: AccessibilityId.acceptPopUpButton)

                                presenter.showLeanplumAlert(title, text:message, image:image, action: okAction)
                                return true
        })
        Leanplum.defineAction(LPMessageType.interstitial.rawValue,
                              of: LeanplumActionKind(rawValue: 0b11),
                              withArguments: arguments,
                              withOptions: [:],
                              withResponder:  { (context: LPActionContext?) -> Bool in
                                guard let lpMessage = makeLPMessage(from: context,
                                                                    type: LPMessageType.interstitial.rawValue)
                                    else { return true }
                                presenter.showLPMessageAlert(lpMessage)
                                return true


        })

        Leanplum.defineAction(LPMessageType.centerPopup.rawValue,
                              of: LeanplumActionKind(rawValue: 0b11),
                              withArguments: arguments,
                              withOptions: [:],
                              withResponder:  { (context: LPActionContext?) -> Bool in
                                guard let lpMessage = makeLPMessage(from: context,
                                                                    type: LPMessageType.centerPopup.rawValue)
                                    else { return true }
                                presenter.showLPMessageAlert(lpMessage)
                                return true
        })
    }

    private static func makeLPMessage(from context: LPActionContext?, type: String) -> LPMessage? {
        guard let type = LPMessageType(rawValue: type) else { return nil }
        guard let context = context,
            let message = context.stringNamed(Keys.messageText),
            let image = context.fileNamed(Keys.image),
            let buttonText = context.stringNamed(Keys.buttonText),
            let title = context.stringNamed(Keys.title),
            let imageBanner = UIImage(contentsOfFile: image) else { return nil }

        let okAction = UIAction(interface: .styledText(buttonText, .standard),
                                action: { context.runTrackedActionNamed(Keys.action) },
                                accessibility: AccessibilityId.acceptPopUpButton)

        return LPMessage(type: type, headline: title, subHeadline: message, image: imageBanner, action: okAction)
    }
}
