//
//  ChatHeadGroupView.swift
//  LetGo
//
//  Created by Albert Hernández López on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import UIKit

protocol ChatHeadGroupViewDelegate: class {
    func chatHeadGroup(view: ChatHeadGroupView, openChatDetailWithId id: String)
    func chatHeadGroupOpenChatList(view: ChatHeadGroupView)
}

final class ChatHeadGroupView: UIView {
    static let chatHeadSide: CGFloat = 50
    private static let countContainerMinSide: CGFloat = 22
    private static let chatHeadSpacing: CGFloat = 3

    private let chatHeadsContainer: UIView
    private var chatHeads: [ChatHeadView]
    private let countContainer: UIView
    private let countLabel: UILabel

    private var leadingConstraints: [NSLayoutConstraint]
    private var trailingConstraints: [NSLayoutConstraint]
    private var countContainerLeading: NSLayoutConstraint?
    private var countContainerTrailing: NSLayoutConstraint?
    private(set) var isLeftPositioned: Bool

    weak var delegate: ChatHeadGroupViewDelegate?


    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        self.chatHeads = []
        self.chatHeadsContainer = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.countContainer = UIView(frame: CGRect(x: frame.width, y: frame.height,
            width: ChatHeadGroupView.countContainerMinSide, height: ChatHeadGroupView.countContainerMinSide))
        self.countLabel = UILabel(frame: CGRect(x: 0, y: 0,
            width: ChatHeadGroupView.countContainerMinSide, height: ChatHeadGroupView.countContainerMinSide))

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

    override func layoutSubviews() {
        super.layoutSubviews()
        countContainer.layer.cornerRadius = countContainer.frame.height / 2
    }
}


// MARK: - Public methods

extension ChatHeadGroupView {
    func setChatHeads(datas: [ChatHeadData]) {
        chatHeads.forEach { removeChatHeadView($0) }
        datas.forEach { addChatHead($0) }
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
            if let countContainerLeading = countContainerLeading, countContainerTrailing = countContainerTrailing {
                removeConstraint(countContainerLeading)
                addConstraint(countContainerTrailing)
            }
        } else {
            for (idx, leading) in leadingConstraints.enumerate() {
                leading.constant = CGFloat(-idx) * ChatHeadGroupView.chatHeadSpacing
            }
            for (idx, trailing) in trailingConstraints.enumerate() {
                trailing.constant = CGFloat(-idx) * ChatHeadGroupView.chatHeadSpacing
            }
            if let countContainerLeading = countContainerLeading, countContainerTrailing = countContainerTrailing {
                removeConstraint(countContainerTrailing)
                addConstraint(countContainerLeading)
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

    func setBadge(badge: Int) {
        let actualBadge = max(1, badge)
        countLabel.text = badge > 99 ? "+99" : String(actualBadge)
    }
}


// MARK: - Private methods
// MARK: > UI

private extension ChatHeadGroupView {
    func setupUI() {
        chatHeadsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatHeadsContainer)

        countContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countContainer)

        countContainer.backgroundColor = UIColor.primaryColor
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .Center
        countLabel.font = UIFont.systemSemiBoldFont(size: 13)
        countContainer.clipsToBounds = true
        countContainer.addSubview(countLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pressed))
        addGestureRecognizer(tapGesture)
    }

    func setupConstraints() {
        let chcViews: [String: AnyObject] = ["chc": chatHeadsContainer]
        let chcHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[chc]-0-|",
                                                                             options: [], metrics: nil, views: chcViews)
        addConstraints(chcHConstraints)
        let chcVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[chc]-0-|",
                                                                             options: [], metrics: nil, views: chcViews)
        addConstraints(chcVConstraints)

        let ccLeading = NSLayoutConstraint(item: countContainer, attribute: .Leading, relatedBy: .Equal,
                                           toItem: self, attribute: .Leading,
                                           multiplier: 1, constant: ChatHeadGroupView.countContainerMinSide + ChatHeadGroupView.countContainerMinSide/2)
        let ccTrailing = NSLayoutConstraint(item: countContainer, attribute: .Trailing, relatedBy: .Equal,
                                            toItem: self, attribute: .Trailing,
                                            multiplier: 1, constant: -(ChatHeadGroupView.countContainerMinSide + ChatHeadGroupView.countContainerMinSide/2))
        let ccTop = NSLayoutConstraint(item: countContainer, attribute: .Top, relatedBy: .Equal,
                                       toItem: self, attribute: .Top,
                                       multiplier: 1, constant: -ChatHeadGroupView.countContainerMinSide/4)
        let ccWidth = NSLayoutConstraint(item: countContainer, attribute: .Width, relatedBy: .GreaterThanOrEqual,
                                         toItem: nil, attribute: .Width,
                                         multiplier: 1, constant: ChatHeadGroupView.countContainerMinSide)
        let ccHeight = NSLayoutConstraint(item: countContainer, attribute: .Height, relatedBy: .Equal,
                                          toItem: nil, attribute: .Height,
                                          multiplier: 1, constant: ChatHeadGroupView.countContainerMinSide)
        addConstraints([ccTrailing, ccTop, ccWidth, ccHeight])
        countContainerLeading = ccLeading
        countContainerTrailing = ccTrailing

        let clViews: [String: AnyObject] = ["cl": countLabel]
        let clHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-2-[cl]-2-|",
                                                                             options: [], metrics: nil, views: clViews)
        addConstraints(clHConstraints)
        let clVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cl]-0-|",
                                                                             options: [], metrics: nil, views: clViews)
        addConstraints(clVConstraints)
        countContainer.addSubview(countLabel)
    }

    func addChatHead(data: ChatHeadData) -> Bool {
        guard !chatHeads.contains({ return $0.id == data.id }) else { return false }

        let chatHeadView = ChatHeadView(data: data)
        addChatHeadSubview(chatHeadView)
        return true
    }

    func removeChatHead(data: ChatHeadData) -> Bool {
        return removeChatHeadWithId(data.id)
    }

    func removeChatHeadView(chatHead: ChatHeadView) -> Bool {
        return removeChatHeadWithId(chatHead.id)
    }

    func removeChatHeadWithId(id: String) -> Bool {
        guard let idx = chatHeads.indexOf({ return $0.id == id }) else { return false }
        removeChatHeadAtIndex(idx)
        return true
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
        guard !chatHeads.isEmpty else { return }

        if chatHeads.count == 1 {
            delegate?.chatHeadGroup(self, openChatDetailWithId: chatHeads[0].id)
        } else {
            delegate?.chatHeadGroupOpenChatList(self)
        }
    }
}
