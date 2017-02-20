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

enum WebSocketError: Error {
    case notAuthenticated
    case internalError
    case userNotVerified
    case suspended(withCode: Int)

    init(wsErrorType: WebSocketErrorType) {
        switch wsErrorType {
        case .userNotVerified:
            self = .userNotVerified
        default:
            self = .internalError
        }
    }
}

protocol WebSocketClient {
    init(withEndpoint endpoint: String)
    
    var eventBus: PublishSubject<ChatEvent> { get }
    var socketStatus: Variable<WebSocketStatus> { get }

    var openCompletion: (() -> ())? { get set }
    var closeCompletion: (() -> ())? { get set }

    func resumeOperations()
    func suspendOperations()
    func cancelOperations()

    func openWebSocket()
    func closeWebSocket()
    func sendQuery(_ request: WebSocketQueryRequestConvertible, completion: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)?)
    func sendCommand(_ request: WebSocketCommandRequestConvertible, completion: ((Result<Void, WebSocketError>) -> Void)?)
    func sendEvent(_ request: WebSocketEventRequestConvertible)
}
