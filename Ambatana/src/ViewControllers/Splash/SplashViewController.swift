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

class SplashViewController: UIViewController {

    var completionBlock: (Bool -> Void)?
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(nibName: "SplashViewController", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
   
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyUserManager.sharedInstance.saveMyUserIfNew { [weak self] (result: Result<User, UserSaveServiceError>) in
            self?.completionBlock?(result.value != nil)
            PushManager.sharedInstance.updateUrbanAirshipUserAlias()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}
