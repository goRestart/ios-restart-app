//
//  Reporter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public typealias Domain = String

public protocol Reporter {
    func report(domain: Domain, code: Int, message: String)
}
