//
//  ChatDetailBlockedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatDetailBlockedViewController: UIViewController {
    private let viewModel: ChatDetailBlockedViewModel

    private let productView: ChatProductView
    private let relationInfoView: RelationInfoView
    private let chatBlockedMessageView: ChatBlockedMessageView


    // MARK: - Lifecycle

    init(viewModel: ChatDetailBlockedViewModel) {
        self.viewModel = viewModel
        self.productView = ChatProductView.chatProductView()
        self.relationInfoView = RelationInfoView.relationInfoView()
        self.chatBlockedMessageView = ChatBlockedMessageView.chatBlockedMessageView()
        super.init(nibName: "ChatDetailBlockedViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()

        addSubviews()
        setupConstraints()
        setupUI()
    }

}

private extension ChatDetailBlockedViewController {
    private func setupNavigationBar() {
        productView.height = navigationBarHeight
        productView.layoutIfNeeded()

        setLetGoNavigationBarStyle(productView)
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "optionsBtnPressed")
    }
    func addSubviews() {
        relationInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(relationInfoView)
        chatBlockedMessageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatBlockedMessageView)
    }
    func setupConstraints() {
        var views: [String: AnyObject] = ["riv": relationInfoView]
        let rivHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[riv]-0-|", options: [],
                                                                             metrics: nil, views: views)
        let rivTopConstraint = NSLayoutConstraint(item: relationInfoView, attribute: .Top, relatedBy: .Equal,
                                                  toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints(rivHConstraints + [rivTopConstraint])

        views = ["cbmv": chatBlockedMessageView]
        let cbmvHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[cbmv]-8-|", options: [],
                                                                              metrics: nil, views: views)
        let cbmvBottomConstraint = NSLayoutConstraint(item: chatBlockedMessageView, attribute: .Bottom,
                                                      relatedBy: .Equal, toItem: view, attribute: .Bottom,
                                                      multiplier: 1, constant: -8)
        view.addConstraints(cbmvHConstraints + [cbmvBottomConstraint])
    }
    func setupUI() {
        if let patternBackground = StyleHelper.emptyViewBackgroundColor {
            view.backgroundColor = patternBackground
        }

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
    func setupProductView() {
//        productView.userName.text = viewModel.otherUserName
//        productView.productName.text = viewModel.productName
//        productView.productPrice.text = viewModel.productPrice
//
//        if let thumbURL = viewModel.productImageUrl {
//            productView.productImage.lg_setImageWithURL(thumbURL)
//        }
//
//        let placeholder = LetgoAvatar.avatarWithID(viewModel.otherUserID, name: viewModel.otherUserName)
//        productView.userAvatar.image = placeholder
//        if let avatar = viewModel.otherUserAvatarUrl {
//            productView.userAvatar.lg_setImageWithURL(avatar, placeholderImage: placeholder)
//        }
//
//        if viewModel.chatStatus == .ProductDeleted {
//            productView.disableProductInteraction()
//        }
//
//        if viewModel.chatStatus == .Forbidden {

//        }
        productView.disableUserProfileInteraction()
        productView.disableProductInteraction()
    }
}
