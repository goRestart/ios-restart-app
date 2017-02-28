//
//  ReceiptURLProvider.swift
//  LetGo
//
//  Created by Dídac on 27/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol ReceiptURLProvider {
    var appStoreReceiptURL: URL? { get }
}

extension Bundle: ReceiptURLProvider {}
