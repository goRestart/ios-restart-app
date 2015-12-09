//
//  CustomPermissionView.swift
//  LetGo
//
//  Created by Dídac on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public enum PrePermissionType: Int {
    case ProductList
    case Sell
    case Chat

    public var title: String {
        switch (self) {
        case ProductList:
            return LGLocalizedString.customPermissionListTitle
        case Sell:
            return LGLocalizedString.customPermissionSellTitle
        case Chat:
            return LGLocalizedString.customPermissionChatTitle
        }
    }

    public var message: String {
        switch (self) {
        case ProductList:
            return LGLocalizedString.customPermissionListMessage
        case Sell:
            return LGLocalizedString.customPermissionSellMessage
        case Chat:
            return LGLocalizedString.customPermissionChatMessage
        }
    }

    public var image: String {
        switch (self) {
        case ProductList:
            return "custom_permission_list"
        case Sell:
            return "custom_permission_sell"
        case Chat:
            return "custom_permission_chat"
        }
    }

    public var trackingParam: EventParameterPermissionTypePage {
        switch (self) {
        case ProductList:
            return .ProductList
        case Sell:
            return .Sell
        case Chat:
            return .Chat
        }
    }
}

public class CustomPermissionView: UIView {

    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var customAlertView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activateButton: UIButton!

    var handler : ((Bool) -> ())?

    
    public static func customPermissionView() -> CustomPermissionView? {
        return NSBundle.mainBundle().loadNibNamed("CustomPermissionView", owner: self, options: nil).first
            as? CustomPermissionView
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func setupCustomAlertWithTitle(title: String, message: String, imageName: String, activateButtonTitle: String,
        cancelButtonTitle: String, handler: ((Bool) -> ())?) {

            self.handler = handler

            alpha = 0
            showWithFadeIn()

            bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

            customAlertView.layer.cornerRadius = 6

            cancelButton.layer.cornerRadius = 4
            cancelButton.layer.borderColor = StyleHelper.badgeBgColor.CGColor
            cancelButton.layer.borderWidth = 1
            cancelButton.setTitle(cancelButtonTitle, forState: .Normal)

            activateButton.layer.cornerRadius = 4
            activateButton.setTitle(activateButtonTitle, forState: .Normal)
            
            titleLabel.text = title
            
            messageLabel.text = message

            imageView.image = UIImage(named: imageName)
    }

    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        closeWithFadeOut()
        handler?(false)
    }

    @IBAction func activateButtonPressed(sender: AnyObject) {
        handler?(true)
        removeFromSuperview()
    }


    func showWithFadeIn() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
        })
    }

    func closeWithFadeOut() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 0
            }) { (completed) -> Void in
                self.removeFromSuperview()
        }
    }
}
