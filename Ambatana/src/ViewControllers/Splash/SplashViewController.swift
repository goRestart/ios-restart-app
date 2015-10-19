//
//  SplashViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import UIKit
import Result

class SplashViewController: BaseViewController {

    var completionBlock: (Bool -> Void)?
    
    // MARK: - Lifecycle
    
    init() {
        super.init(viewModel: nil, nibName: "SplashViewController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    internal override func viewWillAppearFromBackground(fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        
        UpdateFileCfgManager.sharedInstance.getUpdateCfgFileFromServer { (forceUpdate: Bool) -> Void in
            
            let itunesURL = String(format: Constants.appStoreURL, arguments: [EnvironmentProxy.sharedInstance.appleAppId])
            
            if forceUpdate && UIApplication.sharedApplication().canOpenURL(NSURL(string:itunesURL)!) == true{
                // show blocking alert
                let alert = UIAlertController(title: NSLocalizedString("forced_update_title", comment: ""), message: NSLocalizedString("forced_update_message", comment: ""), preferredStyle: .Alert)
                let openAppStore = UIAlertAction(title: NSLocalizedString("forced_update_update_button", comment: ""), style: .Default, handler: { (action :UIAlertAction!) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string:itunesURL)!)
                })
                
                alert.addAction(openAppStore)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                MyUserManager.sharedInstance.saveMyUserIfNew { [weak self] (result: UserSaveServiceResult) in
                    self?.completionBlock?(result.value != nil)

                    // TODO: refactor this two calls
                    PushManager.sharedInstance.updateUrbanAirshipNamedUser(result.value)
                    
                    if let myUser = MyUserManager.sharedInstance.myUser() {
                        TrackerProxy.sharedInstance.setUser(myUser)
                    }
                }
                
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    
}
