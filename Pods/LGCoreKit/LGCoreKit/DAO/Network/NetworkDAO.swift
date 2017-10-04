//
//  NetworkDAO.swift
//  LGCoreKit
//
//  Created by Facundo Menzella on 02/10/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol NetworkDAO {
    var timeoutIntervalForRequests: TimeInterval? { get set }
}
