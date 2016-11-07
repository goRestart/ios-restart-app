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
    private static let chatHeadSpacing: CGFloat = 3

    private let chatHeadsContainer: UIView
    private var chatHeads: [ChatHeadView]
    private var leadingConstraints: [NSLayoutConstraint]
    private var trailingConstraints: [NSLayoutConstraint]
    private(set) var isLeftPositioned: Bool


    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        self.chatHeads = []
        self.chatHeadsContainer = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.leadingConstraints = []
        self.trailingConstraints = []
        self.isLeftPositioned = true
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

    func setLeftPositioned(leftPositioned: Bool, animated: Bool) {
        guard isLeftPositioned != leftPositioned else { return }

        if leftPositioned {
            for (idx, leading) in leadingConstraints.enumerate() {
                leading.constant = CGFloat(idx) * ChatHeadGroupView.chatHeadSpacing
            }
            for (idx, trailing) in trailingConstraints.enumerate() {
                trailing.constant = CGFloat(idx) * ChatHeadGroupView.chatHeadSpacing
            }
        } else {
            for (idx, leading) in leadingConstraints.enumerate() {
                leading.constant = CGFloat(-idx) * ChatHeadGroupView.chatHeadSpacing
            }
            for (idx, trailing) in trailingConstraints.enumerate() {
                trailing.constant = CGFloat(-idx) * ChatHeadGroupView.chatHeadSpacing
            }
        }
        isLeftPositioned = leftPositioned

        let animations: () -> () = { [weak self] in self?.layoutIfNeeded() }
        if animated {
            UIView.animateWithDuration(0.15, animations: animations)
        } else {
            animations()
        }
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
        let firstAddition = chatHeads.isEmpty
        chatHeads.append(chatHead)

        chatHead.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatHead)
        sendSubviewToBack(chatHead)

        let leading: NSLayoutConstraint
        let trailing: NSLayoutConstraint
        let spacing = CGFloat(chatHeads.count) * ChatHeadGroupView.chatHeadSpacing
        switch (firstAddition, isLeftPositioned) {
        case (true, _):
            leading = NSLayoutConstraint(item: chatHead, attribute: .Leading, relatedBy: .Equal,
                                         toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
            trailing = NSLayoutConstraint(item: chatHead, attribute: .Trailing, relatedBy: .Equal,
                                          toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        case (false, true):
            leading = NSLayoutConstraint(item: chatHead, attribute: .Leading, relatedBy: .Equal,
                                         toItem: self, attribute: .Leading, multiplier: 1, constant: -spacing)
            trailing = NSLayoutConstraint(item: chatHead, attribute: .Trailing, relatedBy: .Equal,
                                          toItem: self, attribute: .Trailing, multiplier: 1, constant: -spacing)
        case (false, false):
            leading = NSLayoutConstraint(item: chatHead, attribute: .Leading, relatedBy: .Equal,
                                         toItem: self, attribute: .Leading, multiplier: 1, constant: spacing)
            trailing = NSLayoutConstraint(item: chatHead, attribute: .Trailing, relatedBy: .Equal,
                                          toItem: self, attribute: .Trailing, multiplier: 1, constant: spacing)
        }
        leadingConstraints.append(leading)
        trailingConstraints.append(trailing)

        let width = NSLayoutConstraint(item: chatHead, attribute: .Width, relatedBy: .Equal,
                                       toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: ChatHeadGroupView.chatHeadSide)
        addConstraints([leading, trailing, width])

        let views: [String: AnyObject] = ["ch": chatHead]
        var metrics: [String: AnyObject] = [:]
        metrics["chs"] = ChatHeadGroupView.chatHeadSide
        metrics["spacing"] = -CGFloat(chatHeads.count) * ChatHeadGroupView.chatHeadSpacing
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[ch(chs)]-0-|",
                                                                          options: [], metrics: metrics, views: views)
        addConstraints(vConstraints)
    }

    func removeChatHeadAtIndex(index: Int) {
        guard 0..<chatHeads.count ~= index else { return }
        let chatHead = chatHeads.removeAtIndex(index)
        chatHead.removeFromSuperview()

        if 0..<leadingConstraints.count ~= index {
            leadingConstraints.removeAtIndex(index)
        }
        if 0..<trailingConstraints.count ~= index {
            trailingConstraints.removeAtIndex(index)
        }
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
