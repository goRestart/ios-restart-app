//
//  CommercializerTemplate.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol CommercializerTemplate: BaseModel {
    var thumbURL: String? { get }
    var title: String? { get }
    var duration: Int? { get }
    var countryCode: String? { get }
    
    var videoM3u8URL: String? { get }
    var videoHighURL: String? { get }
    var videoLowURL: String? { get }
}
