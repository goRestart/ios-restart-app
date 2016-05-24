//
//  ChatAlertView.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class ChatBlockedMessageView: UIView {
    private static let buttonVisibleHeight: CGFloat = 30
    private static let buttonVisibleBottom: CGFloat = 8

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!

    private var buttonAction: (() -> Void)?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    static func chatBlockedMessageView() -> ChatBlockedMessageView {
        let view = NSBundle.mainBundle().loadNibNamed("ChatBlockedMessageView",
                                                      owner: self, options: nil).first as! ChatBlockedMessageView
        view.setupUI()
        view.setupRxBindings()
        return view
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.setStyle(.Primary(fontSize: .Small))
    }
}


// MARK: - Public methods

extension ChatBlockedMessageView {
    func setMessage(message: NSAttributedString) {
        messageLabel.attributedText = message
    }

    func setButton(title title: String) {
        button.setTitle(title, forState: .Normal)
    }

    func setButton(action action: (() -> Void)?) {
        buttonAction = action

        let buttonHidden = action == nil
        buttonHeightConstraint.constant = buttonHidden ? 0 : ChatBlockedMessageView.buttonVisibleHeight
        buttonBottomConstraint.constant = buttonHidden ? 0 : ChatBlockedMessageView.buttonVisibleBottom
        button.hidden = buttonHidden
    }
}


// MARK: - Private methods

private extension ChatBlockedMessageView {
    func setupUI() {
        let pale = UIColor(rgb: 0xfff1d2)   // 255, 241, 210
        let warmGray = UIColor(rgb: 0x757575)  // 117, 117, 117
//        let border = 

        layer.cornerRadius = 5
        backgroundColor = pale

        messageLabel.textColor = warmGray
        messageLabel.font = UIFont.systemFont(size: 17)
        button.setStyle(.Primary(fontSize: .Small))

        StyleHelper.applyDefaultShadow(layer)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    func setupRxBindings() {
        button.rx_tap.asObservable().subscribeNext { [weak self] _ in
            self?.buttonAction?()
        }.addDisposableTo(disposeBag)
    }
}
