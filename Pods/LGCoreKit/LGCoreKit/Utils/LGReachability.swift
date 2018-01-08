//
//  LGReachability.swift
//  LGCoreKit
//
//  Created by Nestor on 03/02/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import Reachability

public protocol ReachabilityProtocol: class {
    
    /** Called on rachability changes with a final value of reachable 
     - note: also called when changing from 3G to Wi-Fi
     */
    var reachableBlock: (() -> Void)? { get set }
    var unreachableBlock: (() -> Void)? { get set }
    var isReachable: Bool? { get }
    func start()
    func stop()
}

public class LGReachability: ReachabilityProtocol {
    
    private let reachability: Reachability?
    
    public var reachableBlock: (() -> Void)? {
        didSet {
            if let block = reachableBlock {
                reachability?.whenReachable = { _ in
                    block()
                }
            } else {
                reachability?.whenReachable = nil
            }
        }
    }
    
    public var unreachableBlock: (() -> Void)? {
        didSet {
            if let block = unreachableBlock {
                reachability?.whenUnreachable = { _ in
                    block()
                }
            } else {
                reachability?.whenUnreachable = nil
            }
        }
    }
    
    public var isReachable: Bool? {
        get {
            return reachability?.connection != .none
        }
    }
    
    
    // MARK: - Lifecycle
    
    public init() {
        reachability = Reachability()
    }
    
    public func start() {
        do {
            try reachability?.startNotifier()
        } catch {
            logMessage(.error, type: .networking, message: "Could not start Reachability")
        }
    }
    
    public func stop() {
        reachableBlock = nil
        unreachableBlock = nil
        reachability?.stopNotifier()
    }
    
    deinit {
        stop()
    }
}
