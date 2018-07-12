//
//  MockReachability.swift
//  LGCoreKit
//
//  Created by Nestor on 02/02/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

open class MockReachability: ReachabilityProtocol {
    
    public init() {}
    
    // MARK: - Testing
    
    public var isActive: Bool = false
    
    public var isOnline: Bool = false {
        didSet {
            guard isActive else { return }
            performBlock()
        }
    }
    
    public func performBlock() {
        isOnline ? reachableBlock?(.wifi) : unreachableBlock?(.none)
    }
    
    // MARK: - ReachableNotifier Protocol
    public var reachableBlock: ((LGConnection) -> Void)?
    public var unreachableBlock: ((LGConnection) -> Void)?
    
    public var isReachable: Bool? {
        get {
            if isActive {
                return isOnline
            }
            return nil
        }
    }
    
    public func start() {
        isActive = true
        performBlock() // perform an initial check (same as Reachability)
    }
    
    public func stop() {
        isActive = false
    }
}
