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
    private var chatHeadGroupXConstraint: NSLayoutConstraint?
    private var chatHeadGroupYConstraint: NSLayoutConstraint?


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


// MARK: - Overrides

extension ChatHeadOverlayView {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
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
                                                toItem: self, attribute: .Leading, multiplier: 1, constant: 50)
        let chatHeadGroupY = NSLayoutConstraint(item: chatHeadGroup, attribute: .Top, relatedBy: .Equal,
                                                toItem: self, attribute: .Top, multiplier: 1, constant: 50)
        addConstraints([chatHeadGroupX, chatHeadGroupY])

        chatHeadGroupXConstraint = chatHeadGroupX
        chatHeadGroupYConstraint = chatHeadGroupY
    }

    dynamic func panned(recognizer: UIPanGestureRecognizer) {
        guard let chatHeadGroupXConstraint = chatHeadGroupXConstraint,
            chatHeadGroupYConstraint = chatHeadGroupYConstraint else { return }
        switch recognizer.state {
        case .Possible, .Began, .Ended, .Cancelled, .Failed:
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

            // Reset translation
            recognizer.setTranslation(CGPoint.zero, inView: self)

            // Layout the View
            layoutIfNeeded()
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

