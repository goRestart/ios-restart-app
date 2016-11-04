//
//  ChatHeadGroupView.swift
//  LetGo
//
//  Created by Albert Hernández López on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import UIKit

final class ChatHeadGroupView: UIView {
    static let chatHeadSide: CGFloat = 50
    private static let chatHeadSpacing: CGFloat = 5

    private let chatHeadsContainer: UIView
    private var chatHeads: [ChatHeadView]


    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        self.chatHeads = []
        self.chatHeadsContainer = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Public methods

extension ChatHeadGroupView {
    func addChatHead(data: ChatHeadData) -> Bool {
        guard !chatHeads.contains({ return $0.id == data.id }) else { return false }

        let chatHeadView = ChatHeadView(data: data)
        addChatHeadSubview(chatHeadView)
        return true
    }

    func removeChatHeadWithId(id: String) -> Bool {
        guard let idx = chatHeads.indexOf({ return $0.id == id }) else { return false }
        removeChatHeadAtIndex(idx)
        return true
    }

    func removeChatHead(data: ChatHeadData) -> Bool {
        return removeChatHeadWithId(data.id)
    }
}


// MARK: - Private methods
// MARK: > UI

private extension ChatHeadGroupView {
    func setupUI() {
        chatHeadsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatHeadsContainer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pressed))
        addGestureRecognizer(tapGesture)
    }

    func setupConstraints() {
        let views: [String: AnyObject] = ["chc": chatHeadsContainer]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[chc]-0-|",
                                                                          options: [], metrics: nil, views: views)
        addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[chc]-0-|",
                                                                          options: [], metrics: nil, views: views)
        addConstraints(vConstraints)
    }

    func addChatHeadSubview(chatHead: ChatHeadView) {
        chatHeads.append(chatHead)

        chatHead.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatHead)

        let views: [String: AnyObject] = ["ch": chatHead]
        let metrics: [String: AnyObject] = ["chs": ChatHeadGroupView.chatHeadSide]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[ch(chs)]-0-|",
                                                                          options: [], metrics: metrics, views: views)
        addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[ch(chs)]-0-|",
                                                                          options: [], metrics: metrics, views: views)
        addConstraints(vConstraints)
    }

    func removeChatHeadAtIndex(index: Int) {
        let chatHead = chatHeads.removeAtIndex(index)
        chatHead.removeFromSuperview()
    }

    dynamic func pressed(recognizer: UITapGestureRecognizer) {
        guard chatHeads.count > 0 else { return }

        if chatHeads.count == 1 {
            print("1 chat")
        } else {
            print("more than 1 chat")
        }
    }
}
