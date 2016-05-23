//
//  ChatDetailBlockedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatDetailBlockedViewController: UIViewController {
    let chatBlockedMessageView: ChatBlockedMessageView


    // MARK: - Lifecycle

    init() {
        self.chatBlockedMessageView = ChatBlockedMessageView.chatBlockedMessageView()
        super.init(nibName: "ChatDetailBlockedViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupConstraints()
        setupUI()
    }

}

private extension ChatDetailBlockedViewController {
    func addSubviews() {
        chatBlockedMessageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatBlockedMessageView)
    }
    func setupConstraints() {
        let views: [String: AnyObject] = ["cbmv": chatBlockedMessageView]
        let cbmvHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[cbmv]-8-|", options: [],
                                                                              metrics: nil, views: views)
        let cbmvBottomConstraint = NSLayoutConstraint(item: chatBlockedMessageView, attribute: .Bottom,
                                                      relatedBy: .Equal, toItem: view, attribute: .Bottom,
                                                      multiplier: 1, constant: -8)
        view.addConstraints(cbmvHConstraints + [cbmvBottomConstraint])
    }
    func setupUI() {
        let icon = NSTextAttachment()
        icon.image = UIImage(named: "ic_alert_gray")
        let iconString = NSAttributedString(attachment: icon)
        let chatBlockedMessage = NSMutableAttributedString(attributedString: iconString)
        chatBlockedMessage.appendAttributedString(NSAttributedString(string: " " + "For safety reasons bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "))
        chatBlockedMessageView.setMessage(chatBlockedMessage)
        chatBlockedMessageView.setButton(title: "Tirori")
        chatBlockedMessageView.setButton { 
            print("action")
        }
    }
}
