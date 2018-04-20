//
//  ChatInactiveConversationDetailsViewController.swift
//  LetGo
//
//  Created by Nestor on 18/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit
import RxSwift

class ChatInactiveConversationDetailsViewController:
    BaseViewController,
    UITableViewDataSource,
    UITableViewDelegate,
ChatInactiveConversationsViewModelDelegate {
    
    let viewModel: ChatInactiveConversationDetailsViewModel
    let listingView: ChatListingView
    let relationInfoView = RelationInfoView.relationInfoView()
    let tableView = UITableView()
    var selectedCellIndexPath: IndexPath?
    
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    init(viewModel: ChatInactiveConversationDetailsViewModel) {
        self.viewModel = viewModel
        self.listingView = ChatListingView.chatListingView()
        super.init(viewModel: viewModel, nibName: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                               name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuControllerWillHide(_:)),
                                               name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: > UI
    
    private func setupUI() {
        setupNavigationBar()
        setupRelationInfoView()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        setupListingView()
        setNavBarTitleStyle(.custom(listingView))
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "optionsBtnPressed")
    }
    
    private func setupRelationInfoView() {
        relationInfoView.setupUIForStatus(.inactiveConversation, otherUserName: nil)
        relationInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(relationInfoView)
        relationInfoView.layout(with: view).left().right()
        if #available(iOS 11, *) {
            relationInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            relationInfoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.grayBackground
        tableView.allowsSelection = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layout(with: relationInfoView).top(to: .bottom)
        tableView.layout(with: view).left().right()
        if #available(iOS 11, *) {
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        if let patternBackground = UIColor.emptyViewBackgroundColor {
            tableView.backgroundColor = .clear
            view.backgroundColor = patternBackground
        }
        invertTable()
        ChatCellDrawerFactory.registerCells(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func invertTable() {
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    func setupListingView() {
        listingView.height = navigationBarHeight
        listingView.listingName.text = viewModel.listingName
        listingView.listingPrice.text = viewModel.listingPrice
        if let listingImageURL = viewModel.listingImageURL {
            listingView.listingImage.lg_setImageWithURL(listingImageURL)
        }
        listingView.userName.text = viewModel.interlocutorName
        if let interlocutorAvatarURL = viewModel.interlocutorAvatarURL {
            listingView.userAvatar.lg_setImageWithURL(interlocutorAvatarURL,
                                                      placeholderImage: viewModel.interlocutorAvatarPlaceholder)
        } else {
            listingView.userAvatar.image = viewModel.interlocutorAvatarPlaceholder
        }
        listingView.disableListingInteraction()
        listingView.disableUserProfileInteraction()
    }
    
    // MARK: - Actions
    
    @objc private func optionsBtnPressed() {
        viewModel.openOptionsMenu()
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messagesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.messagesCount, let message = viewModel.messageAtIndex(indexPath.row) else {
            return UITableViewCell()
        }
        
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, meetingsEnabled: viewModel.meetingsEnabled)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)
        
        drawer.draw(cell, message: message)
        UIView.performWithoutAnimation {
            cell.transform = tableView.transform
        }
        
        return cell
    }
    
    // MARK: - Copy/Paste feature
    
    /**
     Listen to UIMenuController Will Show notification and update the menu position if needed.
     By default, the menu is shown in the middle of the tableView, this method repositions it to the middle of the bubble
     
     - parameter notification: NSNotification received
     */
    @objc func menuControllerWillShow(_ notification: Notification) {
        guard let indexPath = selectedCellIndexPath else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatBubbleCell else { return }
        selectedCellIndexPath = nil
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIMenuControllerWillShowMenu,
                                                  object: nil)
        
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: false)
        let newFrame = tableView.convert(cell.bubbleView.frame, from: cell)
        menu.setTargetRect(newFrame, in: tableView)
        menu.setMenuVisible(true, animated: true)
    }
    
    @objc func menuControllerWillHide(_ notification: Notification) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                               name: NSNotification.Name.UIMenuControllerWillShowMenu,
                                               object: nil)
    }
    
    func tableView(_ tableView: UITableView,
                   shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        guard let message = viewModel.messageAtIndex(indexPath.row), message.copyEnabled else { return false }
        selectedCellIndexPath = indexPath //Need to save the currently selected cell to reposition the menu later
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   canPerformAction action: Selector,
                   forRowAt indexPath: IndexPath,
                   withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            guard let cell = tableView.cellForRow(at: indexPath) else { return false }
            cell.setSelected(true, animated: true)
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView,
                   performAction action: Selector,
                   forRowAt indexPath: IndexPath,
                   withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            UIPasteboard.general.string = viewModel.textOfMessageAtIndex(indexPath.row)
        }
    }
    
    // MARK: - ChatInactiveConversationsViewModel delegate
    
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message: message, completion: completion)
    }
    
    // MARK: - Accesibility
    
    func setupAccessibilityIds() {
        tableView.set(accessibilityId: .inactiveChatViewTableView)
        navigationItem.rightBarButtonItem?.set(accessibilityId: .inactiveChatViewMoreOptionsButton)
        navigationItem.backBarButtonItem?.set(accessibilityId: .inactiveChatViewBackButton)
    }
}
