//
//  LGProductFavourite.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class LGProductFavourite: LGBaseModel, ProductFavourite {
    
    public var product: Product?
    public var user: User?
    
    // MARK: - Lifecycle
    
    public override init() {
        self.product = LGProduct()
        self.user = LGUser()
        
        super.init()
    }
}
