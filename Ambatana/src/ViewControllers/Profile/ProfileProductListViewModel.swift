//
//  ProfileProductListViewModel.swift
//  LetGo
//
//  Created by AHL on 25/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class ProfileProductListViewModel: ProductListViewModel {
   
    // Input
    public var user: User? {
        didSet {
            if let actualUser = user {
                self.userObjectId = actualUser.objectId
            }
        }
    }
    public var type: ProfileProductListViewType {
        didSet {
            switch type {
            case .Selling:
                statuses = [.Pending, .Approved]
                break
            case .Sold:
                statuses = [.Sold]
                break
            }
        }
    }
    
    // MARK: - Lifecycle
    
    public init(user: User? = nil, type: ProfileProductListViewType = .Selling) {
        self.user = user ?? MyUserManager.sharedInstance.myUser()
        self.type = type
        super.init()
    }
}
