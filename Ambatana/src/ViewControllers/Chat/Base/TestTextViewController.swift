//
//  TestTextViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 30/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class TestTextViewController: TextViewController {

    init(){
        super.init(viewModel: nil, nibName: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarBtn = UIBarButtonItem(title: "Close", style: .Done, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = leftBarBtn

        textView.placeholder = LGLocalizedString.chatMessageFieldHint
        textView.placeholderColor = UIColor.gray
        textView.placeholderFont = UIFont.systemFontOfSize(17)
        textView.tintColor = UIColor.primaryColor
        textViewFont = UIFont.systemFontOfSize(17)

        sendButton.setTitle(LGLocalizedString.chatSendButton, forState: .Normal)
        sendButton.tintColor = UIColor.primaryColor
        sendButton.titleLabel?.font = UIFont.smallButtonFont

        let testAction1 = UIAction(interface: .Image(UIImage(named: "ic_stickers")), action: { print("first button pressed")})
        let testAction2 = UIAction(interface: .Image(UIImage(named: "ic_keyboard")), action: { print("second button pressed")})
        leftActions = [testAction1, testAction2]
    }

    dynamic private func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
