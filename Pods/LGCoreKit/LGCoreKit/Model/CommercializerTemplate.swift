//
//  CommercializerTemplate.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol CommercializerTemplate: BaseModel {
    var videoURL: String? { get }
    var thumbURL: String? { get }
    var title: String? { get }
    var duration: Int? { get }
    var countryCode: String? { get }
}
