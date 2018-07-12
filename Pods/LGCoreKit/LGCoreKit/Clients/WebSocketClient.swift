//
//  WebSocketClient.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

// MARK: > Request Protocol

protocol WebSocketRequestConvertible {
    var message: String { get }
    var uuid: String { get }
    var type: WebSocketRequestType { get }
}

protocol WebSocketCommandRequestConvertible: WebSocketRequestConvertible {}
protocol WebSocketEventRequestConvertible: WebSocketRequestConvertible {}
protocol WebSocketQueryRequestConvertible: WebSocketRequestConvertible {}


// MARK: > WebSocket Error

enum WebSocketError: Error, Equatable {
    case notAuthenticated
    case internalError(withCode: Int)
    case userNotVerified
    case userBlocked
    case suspended(withCode: Int)
    case differentCountry
    
    init(wsErrorType: WebSocketErrorType) {
        switch wsErrorType {
        case .userNotVerified:
            self = .userNotVerified
        case .userBlocked:
            self = .userBlocked
        case .userInDifferentCountryError:
            self = .differentCountry
        default:
            self = .internalError(withCode: wsErrorType.rawValue)
        }
    }
}

func ==(lhs: WebSocketError, rhs: WebSocketError) -> Bool {
    switch (lhs, rhs) {
    case (.notAuthenticated, .notAuthenticated), (.userNotVerified, .userNotVerified), (.userBlocked, .userBlocked),
         (.differentCountry, .differentCountry):
        return true
    case (.internalError(let lhsCode), .internalError(let rhsCode)) where lhsCode == rhsCode,
         (.suspended(let lhsCode), .suspended(let rhsCode)) where lhsCode == rhsCode:
        return true
    default:
        return false
    }
}

// MARK: > WebsocketClient

protocol WebSocketClient: class {
    var timeoutIntervalForRequest: TimeInterval { get set }

    var eventBus: PublishSubject<ChatEvent> { get }
    var socketStatus: Variable<WebSocketStatus> { get }
    var tracker: CoreTracker? { get set }

    init(webSocket: WebSocketLibraryProtocol, reachability: ReachabilityProtocol, tracker: CoreTracker?)
    
    func start(withEndpoint endpoint: String)
    func stop()
    func suspendOperations()
    func cancelAllOperations(withError: WebSocketError)
    
    func applicationDidEnterBackground()
    func applicationWillEnterForeground()
    
    func sendQuery(_ request: WebSocketQueryRequestConvertible, completion: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)?)
    func sendCommand(_ request: WebSocketCommandRequestConvertible, completion: ((Result<Void, WebSocketError>) -> Void)?)
    func sendEvent(_ request: WebSocketEventRequestConvertible)
}
