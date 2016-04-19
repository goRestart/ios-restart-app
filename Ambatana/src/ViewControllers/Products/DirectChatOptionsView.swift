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
}

public class DirectChatOptionsView: UIView {

    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var negotiableButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var interestedButton: UIButton!

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
        cancelButton.setTitle(LGLocalizedString.commonCancel, forState: .Normal)
        cancelButton.setSecondaryStyle()
        negotiableButton.setPrimaryStyle()
        negotiableButton.setTitle(LGLocalizedString.productChatDirectOptionButtonNegotiable, forState: .Normal)
        buyButton.setPrimaryStyle()
        buyButton.setTitle(LGLocalizedString.productChatDirectOptionButtonBuy, forState: .Normal)
        interestedButton.setPrimaryStyle()
        interestedButton.setTitle(LGLocalizedString.productChatDirectOptionButtonInterested , forState: .Normal)
        buttonContainerViewHeight = buttonContainerView.frame.size.height
        buttonContainerView.frame = CGRect(origin: CGPointMake(0, frame.height) , size: buttonContainerView.frame.size)
    }

    public func showButtons(completion: ((Bool) -> Void)?) {

        UIView.animateWithDuration(0.35, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.buttonContainerView.frame = CGRect(origin: CGPointMake(0,
                strongSelf.frame.height-strongSelf.buttonContainerViewHeight),
                size: strongSelf.buttonContainerView.frame.size)
            }, completion: completion)
    }

    public func hideButtons(completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(0.35, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.buttonContainerView.frame = CGRect(origin: CGPointMake(0, strongSelf.frame.height),
                size: strongSelf.buttonContainerView.frame.size)
            }, completion: completion)
    }


    // MARK: - Button Actions

    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        hideButtons { [weak self] _ in
            self?.removeFromSuperview()
        }
    }

    @IBAction func onDirectMessageButtonTapped(sender: AnyObject) {
        guard let button = sender as? UIButton, let title =  button.titleLabel?.text else { return }
        delegate?.sendDirectChatWithMessage(title)
        removeFromSuperview()
    }
}
