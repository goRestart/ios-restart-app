//
//  ChatViewController.swift
//  Ambatana
//
//  Created by Nacho on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaConversationMyMessagesCell = "MyMessagesCell"
private let kAmbatanaConversationOthersMessagesCell = "OthersMessagesCell"

private let kAmbatanaConversationCellBubbleTag = 1
private let kAmbatanaConversationCellTextTag = 2
private let kAmbatanaConversationCellRelativeTimeTag = 3
private let kAmbatanaConversationCellAvatarTag = 4


class ChatViewController: UIViewController {
    // outlets & buttons
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // internationalization
        messageTextfield.placeholder = translate("type_your_message_here")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    
    @IBAction func sendMessage(sender: AnyObject) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
