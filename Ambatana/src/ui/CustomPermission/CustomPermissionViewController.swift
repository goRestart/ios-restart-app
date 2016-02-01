//
//  CustomPermissionViewController.swift
//  LetGo
//
//  Created by Dídac on 09/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public class CustomPermissionViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var customAlertView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activateButton: UIButton!

    private let prePermissionType: PrePermissionType
    private var handler : ((Bool) -> ())?

    public init(prePermissionType: PrePermissionType, handler: (Bool -> Void)?) {
        self.prePermissionType = prePermissionType
        self.handler = handler
        super.init(nibName: "CustomPermissionViewController", bundle: nil)
        self.modalPresentationStyle = .OverCurrentContext
        self.modalTransitionStyle = .CrossDissolve
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCustomAlertWithTitle(prePermissionType.title, message: prePermissionType.message,
            imageName: prePermissionType.image)
    }

    private func setupCustomAlertWithTitle(title: String, message: String, imageName: String) {

            bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

            customAlertView.layer.cornerRadius = StyleHelper.defaultCornerRadius

            cancelButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
            cancelButton.layer.borderColor = StyleHelper.badgeBgColor.CGColor
            cancelButton.layer.borderWidth = 1
            cancelButton.setTitle(LGLocalizedString.commonCancel, forState: .Normal)

            activateButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
            activateButton.setTitle(LGLocalizedString.commonOk, forState: .Normal)

            titleLabel.text = title
            messageLabel.text = message
            imageView.image = UIImage(named: imageName)
    }


    @IBAction func cancelButtonPressed(sender: AnyObject) {
        handler?(false)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func activateButtonPressed(sender: AnyObject) {
        handler?(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
