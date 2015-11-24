//
//  ChatViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import SlackTextViewController
import LGCoreKit

class ChatViewController: SLKTextViewController, ChatViewModelDelegate {

    private var selectedCellIndexPath: NSIndexPath?
    var viewModel: ChatViewModel
    
    required init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(tableViewStyle: .Plain)
        self.viewModel.delegate = self
        hidesBottomBarWhenPushed = true
    }
    
    required init!(coder decoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        setupUI()
        viewModel.loadMessages()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow:", name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillHide:", name: UIMenuControllerWillHideMenuNotification, object: nil)
    }
    
    func setupUI() {
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.backgroundColor = StyleHelper.chatTableViewBgColor
        tableView.allowsSelection = false
    }
    
    func registerNibs() {
        let myMessageCellNib = UINib(nibName: ChatMyMessageCell.cellID(), bundle: nil)
        tableView.registerNib(myMessageCellNib, forCellReuseIdentifier: ChatMyMessageCell.cellID())
        let othersMessageCellNib = UINib(nibName: ChatOthersMessageCell.cellID(), bundle: nil)
        tableView.registerNib(othersMessageCellNib, forCellReuseIdentifier: ChatOthersMessageCell.cellID())
    }
    
    
    // MARK: UIMenuController observer
    
    /**
    Listen to UIMenuController Will Show notification and update the menu position if needed.
    By default, the menu is shown in the middle of the tableView, this method repositions it to the middle of the bubble
    
    - parameter notification: NSNotification received
    */
    func menuControllerWillShow(notification: NSNotification) {
        guard let indexPath = selectedCellIndexPath else { return }
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatBubbleCell else { return }
        selectedCellIndexPath = nil
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerWillShowMenuNotification, object: nil)
        let menu = UIMenuController.sharedMenuController()
        menu.setMenuVisible(false, animated: false)
        let newFrame = tableView.convertRect(cell.bubbleView.frame, fromView: cell)
        menu.setTargetRect(newFrame, inView: tableView)
        menu.setMenuVisible(true, animated: true)
    }
    
    
    func menuControllerWillHide(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow:", name: UIMenuControllerWillShowMenuNotification, object: nil)
    }
    
    
    // MARK: Slack methods
    
    override func didPressRightButton(sender: AnyObject!) {
        let message = textView.text
        textView.text = ""
        viewModel.sendMessage(message)
    }

    
    // MARK: TableView Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chat.messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = viewModel.chat.messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)
        drawer.draw(cell, message: message, avatar: viewModel.otherUser?.avatar)
        cell.transform = tableView.transform
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    // MARK: - Allow copying text / highlighted state in cells
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        selectedCellIndexPath = indexPath //Need to save the currently selected cell to reposition the menu later
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == "copy:" {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return false }
            cell.setSelected(true, animated: true)
            return true
        }
        return false
    }
    
   override  func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == "copy:" {
            UIPasteboard.generalPasteboard().string = viewModel.chat.messages[indexPath.row].text
        }
    }
    
    
    // MARK: ChatViewModelDelegate
    
    func didFailRetrievingChatMessages(error: ChatRetrieveServiceError) {
        switch (error) {
        case .Internal, .Network, .NotFound, .Unauthorized:
            showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError, completionBlock: { [weak self] () -> Void in
                self?.popBackViewController()
            })
        case .Forbidden:
            // logout the scammer!
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric, completionBlock: { (completion) -> Void in
                MyUserManager.sharedInstance.logout(nil)
            })
        }
    }
    
    func didSucceedRetrievingChatMessages() {
        tableView.reloadData()
    }

    func didFailSendingMessage(error: ChatSendMessageServiceError) {
        switch (error) {
        case .Internal, .Network, .NotFound, .Unauthorized:
            showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError)
        case .Forbidden:
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric, completionBlock: { (completion) -> Void in
                MyUserManager.sharedInstance.logout(nil)
            })
        }
    }
    
    func didSucceedSendingMessage() {
        tableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }

}
