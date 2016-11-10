//
//  ChatHeadOverlayView.swift
//  LetGo
//
//  Created by Albert Hernández López on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

final class ChatHeadOverlayView: UIView {
    private static let snapPointCountPerSide: Int = 5
    private static let chatHeadGroupMargin: CGFloat = -5
    private static let chatHeadDistanceToHide: CGFloat = 35
    private static let deleteShownBottom: CGFloat = 150

    private let chatHeadGroup: ChatHeadGroupView
    private var chatHeadGroupXConstraint: NSLayoutConstraint?
    private var chatHeadGroupYConstraint: NSLayoutConstraint?

    private let deleteImageView: UIImageView
    private var deleteBottomConstraint: NSLayoutConstraint?

    private var placedInMagnetPoint: Bool
    private var magnetPoints: [CGPoint]


    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        self.chatHeadGroup = ChatHeadGroupView()
        self.deleteImageView = UIImageView()
        self.placedInMagnetPoint = false
        self.magnetPoints = []
        super.init(frame: frame)

        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        magnetPoints = generateSnapPoints(ChatHeadOverlayView.snapPointCountPerSide)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        magnetPoints = generateSnapPoints(ChatHeadOverlayView.snapPointCountPerSide)
        snapToNearestMagnetPoint(animated: false)
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        guard !hidden else { return nil }

        /* The only touchable element in the overlay is the chat head group, all others views are ignored.
         Therefore, otherwise hitTest will forward down in the view tree. */
        let convertedPoint = chatHeadGroup.convertPoint(point, fromView: self)
        let insideChatHeadGroup = chatHeadGroup.pointInside(convertedPoint, withEvent: event)
        return insideChatHeadGroup ? chatHeadGroup : nil
    }
}


// MARK: - Public methods

extension ChatHeadOverlayView {
    func setChatHeadDatas(datas: [ChatHeadData]) {
        hidden = false
        chatHeadGroup.setChatHeads(datas)

        if !placedInMagnetPoint {
            placedInMagnetPoint = true
            snapToNearestMagnetPoint(animated: false)
        }
    }

    func setChatHeadGroupViewDelegate(delegate: ChatHeadGroupViewDelegate?) {
        chatHeadGroup.delegate = delegate
    }

    func setBadge(badge: Int) {
        chatHeadGroup.setBadge(badge)
    }
}


// MARK: - Private methods
// MARK: > Setup

private extension ChatHeadOverlayView {
    func setupUI() {
        chatHeadGroup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatHeadGroup)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned))
        chatHeadGroup.addGestureRecognizer(panGesture)

        deleteImageView.translatesAutoresizingMaskIntoConstraints = false
        deleteImageView.image = UIImage(named: "ic_chat_heads_close")
        deleteImageView.highlightedImage = UIImage(named: "ic_chat_heads_delete")
        addSubview(deleteImageView)
    }

    func setupConstraints() {
        let chatHeadGroupX = NSLayoutConstraint(item: chatHeadGroup, attribute: .Leading, relatedBy: .Equal,
                                                toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        let chatHeadGroupY = NSLayoutConstraint(item: chatHeadGroup, attribute: .Top, relatedBy: .Equal,
                                                toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        addConstraints([chatHeadGroupX, chatHeadGroupY])

        chatHeadGroupXConstraint = chatHeadGroupX
        chatHeadGroupYConstraint = chatHeadGroupY

        let deleteCenterX = NSLayoutConstraint(item: deleteImageView, attribute: .CenterX, relatedBy: .Equal,
                                               toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let deleteBottom = NSLayoutConstraint(item: deleteImageView, attribute: .Bottom, relatedBy: .Equal,
                                              toItem: self, attribute: .Bottom,
                                              multiplier: 1, constant: ChatHeadOverlayView.deleteShownBottom)
        deleteBottomConstraint = deleteBottom
        addConstraints([deleteCenterX, deleteBottom])
    }

    func generateSnapPoints(countPerSide: Int) -> [CGPoint] {
        var points = [CGPoint]()

        let max = countPerSide + 1
        let heightSegment = frame.height / CGFloat(max)
        let leftX = ChatHeadOverlayView.chatHeadGroupMargin
        let rightX = frame.width - ChatHeadGroupView.chatHeadSide - ChatHeadOverlayView.chatHeadGroupMargin

        for i in 1..<max {
            let y = heightSegment * CGFloat(i)

            let pointLeft = CGPoint(x: leftX, y: y)
            points.append(pointLeft)

            let pointRight = CGPoint(x: rightX, y: y)
            points.append(pointRight)
        }
        return points
    }
}


// MARK: > Drag 'n' drop

private extension ChatHeadOverlayView {
    dynamic func panned(recognizer: UIPanGestureRecognizer) {
        guard let chatHeadGroupXConstraint = chatHeadGroupXConstraint,
            chatHeadGroupYConstraint = chatHeadGroupYConstraint else { return }
        switch recognizer.state {
        case .Began:
            deleteImageView.highlighted = false
            setDeleteImageViewHidden(false, animated: true)
        case .Possible:
            break
        case .Changed:
            let translation = recognizer.translationInView(self)

            // Update the constraint's constants
            chatHeadGroupXConstraint.constant += translation.x
            chatHeadGroupYConstraint.constant += translation.y

            // Assign the frame's position only for checking it's fully on the screen
            guard var recognizerFrame = recognizer.view?.frame else { return }
            recognizerFrame.origin.x = chatHeadGroupXConstraint.constant
            recognizerFrame.origin.y = chatHeadGroupYConstraint.constant

            // Check if UIImageView is completely inside its superView
            if !CGRectContainsRect(bounds, recognizerFrame) {
                if (chatHeadGroupYConstraint.constant < CGRectGetMinY(bounds)) {
                    chatHeadGroupYConstraint.constant = 0
                } else if (chatHeadGroupYConstraint.constant + CGRectGetHeight(recognizerFrame) > CGRectGetHeight(bounds)) {
                    chatHeadGroupYConstraint.constant = CGRectGetHeight(bounds) - CGRectGetHeight(recognizerFrame)
                }

                if (chatHeadGroupXConstraint.constant < CGRectGetMinX(bounds)) {
                    chatHeadGroupXConstraint.constant = 0
                } else if (chatHeadGroupXConstraint.constant + CGRectGetWidth(recognizerFrame) > CGRectGetWidth(bounds)) {
                    chatHeadGroupXConstraint.constant = CGRectGetWidth(bounds) - CGRectGetWidth(recognizerFrame)
                }
            }

            // Set as left/right positioned
            let leftPositioned = (chatHeadGroupXConstraint.constant + chatHeadGroup.width/2) > CGRectGetMidX(bounds)
            chatHeadGroup.setLeftPositioned(leftPositioned, animated: true)

            // If near delete then highlight it
            let currentPos = CGPoint(x: chatHeadGroupXConstraint.constant, y: chatHeadGroupYConstraint.constant)
            let distance = currentPos.distanceTo(deleteImageView.frame.origin)
            print(distance)
            let highlighted = distance <= ChatHeadOverlayView.chatHeadDistanceToHide
            deleteImageView.highlighted = highlighted

            // Reset translation
            recognizer.setTranslation(CGPoint.zero, inView: self)

            // Layout the View
            layoutIfNeeded()
        case .Ended, .Cancelled, .Failed:
            // If over delete then hide
            let currentPos = CGPoint(x: chatHeadGroupXConstraint.constant, y: chatHeadGroupYConstraint.constant)
            let distance = currentPos.distanceTo(deleteImageView.frame.origin)
            if distance <= ChatHeadOverlayView.chatHeadDistanceToHide {
                hidden = true
            }

            setDeleteImageViewHidden(true, animated: true)
            snapToNearestMagnetPoint(animated: true)
        }
    }

    func setDeleteImageViewHidden(hidden: Bool, animated: Bool) {
        deleteBottomConstraint?.constant = hidden ? ChatHeadOverlayView.deleteShownBottom : -ChatHeadOverlayView.deleteShownBottom
        let animations: () -> () = { [weak self] in
            self?.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
                                       options: [], animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    func snapToNearestMagnetPoint(animated animated: Bool) {
        guard let chatHeadGroupXConstraint = chatHeadGroupXConstraint,
            chatHeadGroupYConstraint = chatHeadGroupYConstraint else { return }

        let currentPoint = CGPoint(x: chatHeadGroupXConstraint.constant,
                                   y: chatHeadGroupYConstraint.constant)
        guard let magnetPoint = currentPoint.nearestPointTo(magnetPoints) else { return }

        snapTo(magnetPoint, animated: animated)
    }

    func snapTo(point: CGPoint, animated: Bool) {
        chatHeadGroupXConstraint?.constant = point.x
        chatHeadGroupYConstraint?.constant = point.y

        let leftPositioned = (point.x + chatHeadGroup.width/2) > CGRectGetMidX(bounds)
        chatHeadGroup.setLeftPositioned(leftPositioned, animated: false)

        let animations: () -> () = { [weak self] in
            self?.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
                                       options: [], animations: animations, completion: nil)
        } else {
            animations()
        }
    }
}
