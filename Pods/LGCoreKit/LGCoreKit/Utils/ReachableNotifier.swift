//
//  ReachableNotifier.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 13/10/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import ReachabilitySwift

protocol ReachableNotifier {
    var onReachable: (() -> Void)? { get set }
    func start()
    func stop()
}

extension Reachability: ReachableNotifier {
    var onReachable: (() -> Void)? {
        set {
            if let callback = newValue {
                whenReachable = { _ in
                    callback()
                }
            } else {
                whenReachable = nil
            }
        }
        get {
            return nil
        }
    }

    func start() {
        do {
            try startNotifier()
        } catch {}
    }

    func stop() {
        stopNotifier()
    }
}
