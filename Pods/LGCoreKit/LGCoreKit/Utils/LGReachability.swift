//
//  LGReachability.swift
//  LGCoreKit
//
//  Created by Nestor on 03/02/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import Reachability

public enum LGConnection: CustomStringConvertible {
    case none, wifi, cellular
    public var description: String {
        switch self {
        case .cellular: return "Cellular"
        case .wifi: return "WiFi"
        case .none: return "No Connection"
        }
    }
}

extension Reachability.Connection {
    var lgConnection: LGConnection {
        switch self {
        case .cellular: return .cellular
        case .wifi: return .wifi
        case .none: return .none
        }
    }
}

public protocol ReachabilityProtocol: class {
    
    /** Called on reachability changes with a final value of reachable
     - note: also called when changing from 3G to Wi-Fi
     */
    var reachableBlock: ((LGConnection) -> Void)? { get set }
    var unreachableBlock: ((LGConnection) -> Void)? { get set }
    var isReachable: Bool? { get }
    func start()
    func stop()
}

public class LGReachability: ReachabilityProtocol {
    
    private let reachability: Reachability?
    
    public var reachableBlock: ((LGConnection) -> Void)? {
        didSet {
            if let block = reachableBlock {
                reachability?.whenReachable = { reachability in
                    block(reachability.connection.lgConnection)
                }
            } else {
                reachability?.whenReachable = nil
            }
        }
    }
    
    public var unreachableBlock: ((LGConnection) -> Void)? {
        didSet {
            if let block = unreachableBlock {
                reachability?.whenUnreachable = { reachability in
                    block(reachability.connection.lgConnection)
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
