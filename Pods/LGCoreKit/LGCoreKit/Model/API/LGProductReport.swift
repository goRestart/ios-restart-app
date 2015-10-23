//
//  LGProductReport.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class LGProductReport: LGBaseModel, ProductReport {
    
    public var product: Product?
    public var userReporter: User?
    public var userReported: User?
    
    // MARK: - Lifecycle
    
    public override init() {
        self.product = LGProduct()
        self.userReporter = LGUser()
        self.userReported = LGUser()
        
        super.init()
    }
}
