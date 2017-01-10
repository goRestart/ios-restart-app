//
//  Leanplum+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 08/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol CustomLeanplumPresenter {
    func showLeanplumAlert(_ title: String?, text: String, image: String, action: UIAction)
}

extension Leanplum {
    
    private static let leanplumCustomPopUp =  "LETGO_POPUP"
    private static let titleIdentifier = "Title"
    private static let messageTextIdentifier = "MessageText"
    private static let imageIdentifier = "Image"
    private static let buttonTextIdentifier = "ButtonText"
    private static let actionIdentifier = "Accept action"
    
    static func customLeanplumAlert(_ presenter: CustomLeanplumPresenter) {
        
        let argumentTitle = LPActionArg(named: titleIdentifier, with: "")
        let argumentMessage = LPActionArg(named: messageTextIdentifier, with: "")
        let argumentImage = LPActionArg(named: imageIdentifier, withFile: nil)
        let argumentButton = LPActionArg(named: buttonTextIdentifier, with: "")
        let argumentAction = LPActionArg(named: actionIdentifier, withAction: nil)
        let arguments = [argumentTitle, argumentMessage, argumentImage, argumentButton, argumentAction]
        // ofKind: LeanplumActionKind | kLeanplumActionKindAction  need to be set as rawValue.
        Leanplum.defineAction(leanplumCustomPopUp, ofKind: LeanplumActionKind(rawValue: 0b11), withArguments: arguments, withResponder:  { context in
            guard let context = context else { return false }
            guard let message = context.stringNamed(messageTextIdentifier) else { return false}
            guard let image = context.fileNamed(imageIdentifier) else { return false}
            guard let buttonText = context.stringNamed(buttonTextIdentifier) else { return false}
            
            let title = context.stringNamed(titleIdentifier)
            let okAction = UIAction(interface: .styledText(buttonText, .default),
                                    action: { context.runTrackedActionNamed(actionIdentifier) },
                                    accessibilityId: .acceptPopUpButton)
            presenter.showLeanplumAlert(title, text:message, image:image, action: okAction)
            return true
        })
    }
}
