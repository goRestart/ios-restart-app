//
//  ChatListViewController.swift
//  Ambatana
//
//  Created by Nacho on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaConversationCellImageTag = 1
private let kAmbatanaConversationCellProductNameTag = 2
private let kAmbatanaConversationCellUserNameTag = 3
private let kAmbatanaConversationCellLastConversationTag = 4
private let kAmbatanaConversationCellDateTag = 5


class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // outlets & buttons
    @IBOutlet weak var noConversationsYet: UILabel!
    @IBOutlet weak var startSellingOrBuyingLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // internationalization
        noConversationsYet.text = translate("no_conversations_yet")
        startSellingOrBuyingLabel.text = translate("start_selling_or_buying")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    
    @IBAction func searchProducts(sender: AnyObject) {
    }

    @IBAction func sellProducts(sender: AnyObject) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Change
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath) as UITableViewCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
