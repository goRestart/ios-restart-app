//
//  ChatHeadOverlayView.swift
//  LetGo
//
//  Created by Albert Hernández López on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

final class ChatHeadOverlayView: UIView {
    private let chatHeadGroup: ChatHeadGroupView


    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        self.chatHeadGroup = ChatHeadGroupView()
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Private methods

private extension ChatHeadOverlayView {
    func setupUI() {
        chatHeadGroup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatHeadGroup)
    }

    func setupConstraints() {
        let views: [String: AnyObject] = ["chg": chatHeadGroup]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[chg]",
                                                                          options: [], metrics: nil, views: views)
        addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[chg]",
                                                                          options: [], metrics: nil, views: views)
        addConstraints(vConstraints)
    }
}
