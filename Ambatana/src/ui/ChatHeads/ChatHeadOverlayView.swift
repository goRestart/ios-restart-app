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
    private static let chatHeadGroupMargin: CGFloat = 15

    private let chatHeadGroup: ChatHeadGroupView
    private var chatHeadGroupXConstraint: NSLayoutConstraint?
    private var chatHeadGroupYConstraint: NSLayoutConstraint?

    private var magnetPoints: [CGPoint]


    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        self.chatHeadGroup = ChatHeadGroupView()
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
        if insideChatHeadGroup {
            return chatHeadGroup
        } else {
            return nil
        }
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

        guard let myUser = Core.myUserRepository.myUser else { return }
        guard let data1 = ChatHeadData(chat: FakeChat(id: "1"), myUser: myUser) else { return }
        chatHeadGroup.addChatHead(data1)
        guard let data2 = ChatHeadData(chat: FakeChat(id: "2"), myUser: myUser) else { return }
        chatHeadGroup.addChatHead(data2)
    }

    func setupConstraints() {
        let chatHeadGroupX = NSLayoutConstraint(item: chatHeadGroup, attribute: .Leading, relatedBy: .Equal,
                                                toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        let chatHeadGroupY = NSLayoutConstraint(item: chatHeadGroup, attribute: .Top, relatedBy: .Equal,
                                                toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        addConstraints([chatHeadGroupX, chatHeadGroupY])

        chatHeadGroupXConstraint = chatHeadGroupX
        chatHeadGroupYConstraint = chatHeadGroupY
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
        case .Possible, .Began:
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

            // Reset translation
            recognizer.setTranslation(CGPoint.zero, inView: self)

            // Layout the View
            layoutIfNeeded()
        case .Ended, .Cancelled, .Failed:
            snapToNearestMagnetPoint(animated: true)
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


// TODO: Erase

import LGCoreKit

struct FakeChat: Chat {
    let objectId: String?
    let product: Product = FakeProduct()
    let userFrom: User = FakeUser()
    let userTo: User = FakeUser()
    let msgUnreadCount: Int = 3
    let messages: [Message] = []
    let updatedAt: NSDate? = nil
    let forbidden: Bool = false
    let archivedStatus: ChatArchivedStatus = .Active

    init(id: String) {
        objectId = id
    }
}

struct FakeProduct: Product {
    let objectId: String? = "12345"
    let name: String? = "feikasso"
    let nameAuto: String? = "feikasso auto"
    let descr: String? = "descripssion del feikasso"
    let price: ProductPrice = .Free
    let currency: Currency = Currency.currencyWithCode("EUR")

    let location: LGLocationCoordinates2D = LGLocationCoordinates2D(latitude: 42, longitude: 2)
    let postalAddress: PostalAddress = PostalAddress.emptyAddress()

    let languageCode: String? = "en"

    let category: ProductCategory = .CarsAndMotors
    let status: ProductStatus = .Approved

    let thumbnail: File? = nil
    let thumbnailSize: LGSize? = nil
    let images: [File] = []

    let user: User = FakeUser()

    let updatedAt : NSDate? = nil
    let createdAt : NSDate? = nil
    let favorite: Bool = false
}

struct FakeUser: User {
    let objectId: String? = "56789"
    let name: String? = "feikuser"
    let avatar: File? = LGFile(id: nil, url: NSURL(string: "https://s-media-cache-ak0.pinimg.com/736x/0b/91/83/0b9183ddb46d58173b4488bb6c0f598b.jpg"))
    let postalAddress: PostalAddress = PostalAddress.emptyAddress()

    let accounts: [Account]? = []
    let ratingAverage: Float? = 3
    let ratingCount: Int? = 3

    let status: UserStatus = .Active

    let isDummy: Bool = false
}

