//
//  DirectChatOptionsView.swift
//  LetGo
//
//  Created by Dídac on 19/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol DirectChatOptionsViewDelegate: class {
    func sendDirectChatWithMessage(message: String)
    func openChat()
}

public class DirectChatOptionsView: UIView {

    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var goToChatButton: UIButton!
    @IBOutlet weak var negotiableButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var interestedButton: UIButton!

    @IBOutlet weak var buttonContainerViewTopConstraint: NSLayoutConstraint!
    
    private var buttonContainerViewHeight: CGFloat = 0.0

    weak var delegate: DirectChatOptionsViewDelegate?

    
    // MARK: - Lifecycle

    public static func instanceFromNib() -> DirectChatOptionsView {
        let view = NSBundle.mainBundle().loadNibNamed("DirectChatOptionsView", owner: self, options: nil).first as! DirectChatOptionsView
        return view
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func setupUI() {
        goToChatButton.setTitle(LGLocalizedString.productChatGoToChat, forState: .Normal)
        goToChatButton.setSecondaryStyle()
        negotiableButton.setPrimaryStyle()
        negotiableButton.setTitle(LGLocalizedString.productChatDirectOptionButtonNegotiable, forState: .Normal)
        buyButton.setPrimaryStyle()
        buyButton.setTitle(LGLocalizedString.productChatDirectOptionButtonBuy, forState: .Normal)
        interestedButton.setPrimaryStyle()
        interestedButton.setTitle(LGLocalizedString.productChatDirectOptionButtonInterested , forState: .Normal)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DirectChatOptionsView.closeView))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    public func showButtons(completion: ((Bool) -> Void)?) {
        buttonContainerViewTopConstraint.constant = -buttonContainerView.height
        UIView.animateWithDuration(0.35, animations: { [weak self] in
            self?.layoutIfNeeded()
            }, completion: completion)
    }

    public func hideButtons(completion: ((Bool) -> Void)?) {
        buttonContainerViewTopConstraint.constant = 0
        UIView.animateWithDuration(0.35, animations: { [weak self] in
            self?.layoutIfNeeded()
            }, completion: completion)
    }


    // MARK: - Button Actions

    @IBAction func onGoToChatButtonTapped(sender: AnyObject) {
        closeView()
        delegate?.openChat()
    }

    @IBAction func onDirectMessageButtonTapped(sender: AnyObject) {
        guard let button = sender as? UIButton, let title =  button.titleLabel?.text else { return }
        delegate?.sendDirectChatWithMessage(title)
        removeFromSuperview()
    }


    // MARK: - private methods

    func closeView() {
        hideButtons { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
}
