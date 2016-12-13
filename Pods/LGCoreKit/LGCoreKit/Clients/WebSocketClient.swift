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

enum WebSocketError: ErrorType {
    case NotAuthenticated
    case Internal
    case UserNotVerified

    init(wsErrorType: WebSocketErrorType) {
        switch wsErrorType {
        case .UserNotVerified:
            self = .UserNotVerified
        default:
            self = .Internal
        }
    }
}

protocol WebSocketClient {
    var eventBus: PublishSubject<ChatEvent> { get }
    var socketStatus: Variable<WebSocketStatus> { get }

    var openCompletion: (() -> ())? { get set }
    var closeCompletion: (() -> ())? { get set }

    func suspendOperations()

    func startWebSocket(endpoint: String)
    func closeWebSocket()
    func sendQuery(request: WebSocketQueryRequestConvertible, completion: (Result<[String: AnyObject], WebSocketError> -> Void)?)
    func sendCommand(request: WebSocketCommandRequestConvertible, completion: (Result<Void, WebSocketError> -> Void)?)
    func sendEvent(request: WebSocketEventRequestConvertible)
}
