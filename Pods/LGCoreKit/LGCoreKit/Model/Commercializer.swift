//
//  Commercializer.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


public enum CommercializerStatus: Int {
    case Unavailable = 0
    case Processing
    case Ready
}

public protocol Commercializer: BaseModel {
    
    var status: CommercializerStatus { get }
    var videoHighURL: String? { get }
    var videoLowURL: String? { get }
    var thumbURL: String? { get }
    var shareURL: String? { get }
    var templateId: String? { get }
    var title: String? { get }
    var duration: Int? { get }
    var updatedAt : NSDate? { get }
    var createdAt : NSDate? { get }
}
