//
//  ChatAskPhoneNumberCell.swift
//  LetGo
//
//  Created by Dídac on 23/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

class ChatAskPhoneNumberCell: ChatBubbleCell, ReusableCell {

    var buttonAction: (() -> Void)?
    @IBOutlet weak var leavePhoneNumberButton: UIButton!

    @IBAction func leavePhoneNumberPressed() {
        buttonAction?()
    }
    
    override func setAccessibilityIds() {
        super.setAccessibilityIds()
        set(accessibilityId: .chatCellContainer(type: .askPhoneNumber))
    }
}
