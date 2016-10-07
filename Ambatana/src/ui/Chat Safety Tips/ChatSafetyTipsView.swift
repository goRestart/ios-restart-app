//
//  ChatSafetyTipsView.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public class ChatSafetyTipsView: UIView {

    // iVars
    // > UI
    @IBOutlet weak var tipsView: UIView!
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    // > Data
    public var dismissBlock: (Void -> Void)?


    // MARK: - Lifecycle
    
    public static func chatSafetyTipsView() -> ChatSafetyTipsView? {
        let view = NSBundle.mainBundle().loadNibNamed("ChatSafetyTipsView", owner: self, options: nil)!.first as? ChatSafetyTipsView
        if let actualView = view {
            actualView.setupUI()
        }
        return view
    }


    // MARK: - Public methods

    func show() {
        guard let _ = superview else { return }
        alpha = 0
        UIView.animateWithDuration(0.4, animations: { [weak self] in
            self?.alpha = 1
        })
    }

    func hide(remove remove: Bool) {
        UIView.animateWithDuration(0.4,
            animations: { [weak self] in
                self?.alpha = 0
            },
            completion: { [weak self] _ in
                if remove {
                    self?.removeFromSuperview()
                }
                self?.dismissBlock?()
            })
    }

    @IBAction func overlayButtonPressed(sender: AnyObject) {
        hide(remove: true)
    }
    
    @IBAction func okButtonPressed(sender: AnyObject) {
        hide(remove: true)
    }

    
    // MARK: - Private methods

    private func setupUI() {
        alpha = 0
        tipsView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        okButton.setStyle(.Primary(fontSize: .Medium))

        titleLabel.text = LGLocalizedString.chatSafetyTipsTitle
        messageLabel.text = LGLocalizedString.chatSafetyTipsMessage
        okButton.setTitle(LGLocalizedString.commonOk, forState: .Normal)

        okButton.accessibilityId = .SafetyTipsOkButton
    }
}
