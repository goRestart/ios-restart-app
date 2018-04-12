//
//  ListingDeckSnapshotType.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol ListingDeckSnapshotType {
    var preview: URL? { get }
    var imageCount: Int { get }
    var isFavoritable: Bool { get }
    var isFavorite: Bool { get }
    var userInfo: ListingVMUserInfo? { get }
    var status: ListingViewModelStatus? { get }
    var isFeatured: Bool { get }
    var productInfo: ListingVMProductInfo? { get }
    var stats: ListingStats? { get }
    var postedDate: Date? { get }
    var socialSharer: SocialSharer { get }
    var socialMessage: SocialMessage? { get }
    var isMine: Bool { get }
}

struct ListingDeckSnapshot: ListingDeckSnapshotType {
    let preview: URL?
    let imageCount: Int
    let isFavoritable: Bool
    let isFavorite: Bool
    let userInfo: ListingVMUserInfo?
    let status: ListingViewModelStatus?
    let isFeatured: Bool
    let productInfo: ListingVMProductInfo?
    let stats: ListingStats?
    let postedDate: Date?
    let socialSharer: SocialSharer
    let socialMessage: SocialMessage?
    let isMine: Bool
}
